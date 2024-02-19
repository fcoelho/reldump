use std::{
    collections::{HashMap, HashSet, VecDeque},
    hash::Hash,
    i32,
};

use clap::Parser;
use itertools::Itertools;
use mysql::{prelude::Queryable, OptsBuilder, Row, Value};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone)]
struct ValueHelper(Value);

impl PartialEq for ValueHelper {
    fn eq(&self, other: &Self) -> bool {
        match (&self.0, &other.0) {
            (Value::NULL, Value::NULL) => true,
            (Value::Bytes(a), Value::Bytes(b)) => a == b,
            (Value::Int(a), Value::Int(b)) => a == b,
            (Value::UInt(a), Value::UInt(b)) => a == b,
            (Value::Float(a), Value::Float(b)) => a == b,
            (Value::Double(a), Value::Double(b)) => a == b,
            (Value::Date(a1, a2, a3, a4, a5, a6, a7), Value::Date(b1, b2, b3, b4, b5, b6, b7)) => {
                a1 == b1 && a2 == b2 && a3 == b3 && a4 == b4 && a5 == b5 && a6 == b6 && a7 == b7
            }
            (Value::Time(a1, a2, a3, a4, a5, a6), Value::Time(b1, b2, b3, b4, b5, b6)) => {
                a1 == b1 && a2 == b2 && a3 == b3 && a4 == b4 && a5 == b5 && a6 == b6
            }
            _ => false,
        }
    }
}

impl Eq for ValueHelper {}

impl Hash for ValueHelper {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        match &self.0 {
            Value::NULL => 0.hash(state),
            Value::Bytes(v) => v.hash(state),
            Value::Int(v) => v.hash(state),
            Value::UInt(v) => v.hash(state),
            Value::Float(v) => v.to_bits().hash(state),
            Value::Double(v) => v.to_bits().hash(state),
            Value::Date(a1, a2, a3, a4, a5, a6, a7) => {
                a1.hash(state);
                a2.hash(state);
                a3.hash(state);
                a4.hash(state);
                a5.hash(state);
                a6.hash(state);
                a7.hash(state);
            }
            Value::Time(a1, a2, a3, a4, a5, a6) => {
                a1.hash(state);
                a2.hash(state);
                a3.hash(state);
                a4.hash(state);
                a5.hash(state);
                a6.hash(state);
            }
        }
    }
}

#[derive(Parser)]
struct Args {
    config_file: String,
}

#[derive(Deserialize, Debug)]
#[serde(untagged)]
enum DumpItem {
    // this must be defined first because serde will try to match this one first
    WithCondition { table: String, condition: String },
    FullTable { table: String },
}

#[derive(Deserialize, Debug)]
struct DumpConfig {
    kind: String,
    host: String,
    port: u16,
    username: String,
    password: String,
    database: String,

    items: Vec<DumpItem>,

    #[serde(default = "default_max_depth")]
    max_depth: i32,

    #[serde(default = "default_min_depth")]
    min_depth: i32,
}

fn default_max_depth() -> i32 {
    i32::MAX
}

fn default_min_depth() -> i32 {
    i32::MIN
}

#[derive(Clone, Debug, PartialEq, Eq, Hash)]
struct ColumnHelper {
    name: String,
    value: ValueHelper,
}

type PrimaryKey = Vec<String>;

#[derive(Clone, Debug, Serialize)]
struct ForeignKeyColumn {
    table_name: String,
    column_name: String,
    referenced_table_name: String,
    referenced_column_name: String,
}

#[derive(Debug, Serialize)]
struct ForeignKeyConstraint {
    table_name: String,
    referenced_table_name: String,
    constraint_name: String,
    columns: Vec<ForeignKeyColumn>,
}

// one table can have multiple sets of foreign keys to multiple tables
type ForeignKeyConstraints = Vec<ForeignKeyConstraint>;

#[derive(Debug)]
enum JobCondition {
    FullTable,
    WithString(String),
    WithValues(Vec<ColumnHelper>),
}

#[derive(Debug)]
struct Job {
    table_name: String,
    condition: JobCondition,
    depth: i32,
}

struct Table {
    name: String,

    primary_key: Option<PrimaryKey>,
    foreign_keys: Option<ForeignKeyConstraints>,
    references: Option<ForeignKeyConstraints>,
}

impl Table {
    pub fn new(table_name: String) -> Self {
        Self {
            name: table_name,
            primary_key: None,
            foreign_keys: None,
            references: None,
        }
    }

    pub fn get_create_table_statement<T: Queryable>(&mut self, conn: &mut T) -> String {
        let result: Option<(String, String)> = conn
            .query_first(format!("SHOW CREATE TABLE {}", self.name))
            .unwrap();

        let (_, statement) = result.unwrap();

        statement
    }

    pub fn get_primary_key<T: Queryable>(&mut self, conn: &mut T) -> &PrimaryKey {
        self.primary_key.get_or_insert_with(|| {
            let columns: Vec<String> = conn
                .exec_map(
                    r"
                        SELECT column_name FROM information_schema.columns
                        WHERE
                        table_schema = database()
                        AND table_name = ?
                        AND column_key = 'PRI'
                        ORDER BY ordinal_position ASC
                    ",
                    (&self.name,),
                    |(column_name,)| column_name,
                )
                .unwrap();

            columns
        })
    }

    pub fn get_foreign_key_constraints<T: Queryable>(
        &mut self,
        conn: &mut T,
    ) -> &ForeignKeyConstraints {
        self.foreign_keys.get_or_insert_with(|| {
            let mut foreign_keys_map = HashMap::<String, ForeignKeyConstraint>::new();

            let rows : Vec<(String, String, String, String, String)> = conn.exec(
                r"
                    SELECT
                        table_name, column_name, referenced_table_name, referenced_column_name, constraint_name
                    FROM
                        information_schema.key_column_usage
                    WHERE
                        table_schema = database()
                        AND table_name = ?
                        AND referenced_table_name IS NOT NULL
                    ORDER BY
                        constraint_name, ordinal_position ASC
                ",                
                (&self.name,),
            ).unwrap();

            for (table_name, column_name, referenced_table_name, referenced_column_name, constraint_name) in rows {
                let column = ForeignKeyColumn {
                    table_name,
                    column_name,
                    referenced_table_name,
                    referenced_column_name,
                };

                foreign_keys_map.entry(constraint_name.clone()).or_insert_with(|| {
                    ForeignKeyConstraint {
                        table_name: column.table_name.clone(),
                        referenced_table_name: column.referenced_table_name.clone(),
                        constraint_name: constraint_name.clone(),
                        columns: Vec::new(),
                    }
                }).columns.push(column);
            }

            foreign_keys_map.into_values().collect()
        })
    }

    pub fn get_reference_constraints<T: Queryable>(
        &mut self,
        conn: &mut T,
    ) -> &ForeignKeyConstraints {
        self.references.get_or_insert_with(|| {
            let mut references_map = HashMap::<String, ForeignKeyConstraint>::new();

            let rows : Vec<(String, String, String, String, String)> = conn.exec(
                r"
                    SELECT
                        table_name, column_name, referenced_table_name, referenced_column_name, constraint_name
                    FROM
                        information_schema.key_column_usage
                    WHERE
                        table_schema = database()
                        AND referenced_table_name = ?
                        AND referenced_column_name IS NOT NULL
                    ORDER BY
                        table_name, constraint_name, position_in_unique_constraint ASC
                ",                
                (&self.name,),
            ).unwrap();

            for (table_name, column_name, referenced_table_name, referenced_column_name, constraint_name) in rows {
                let column = ForeignKeyColumn {
                    table_name,
                    column_name,
                    referenced_table_name,
                    referenced_column_name,
                };

                references_map.entry(constraint_name.clone()).or_insert_with(|| {
                    ForeignKeyConstraint {
                        table_name: column.table_name.clone(),
                        referenced_table_name: column.referenced_table_name.clone(),
                        constraint_name: constraint_name.clone(),
                        columns: Vec::new(),
                    }
                }).columns.push(column);
            }

            references_map.into_values().collect()
        })
    }
}

// fn process_config(config: &DumpConfig, queue: &mut VecDeque<Job>) {
//     for item in config.items.iter() {
//         match item {
//             DumpItem::FullTable { table } => {
//                 queue.push_back(Job {
//                     table_name: table.clone(),
//                     condition: JobCondition::FullTable,
//                     depth: 0,
//                 });
//             }
//             DumpItem::WithCondition { table, condition } => {
//                 queue.push_back(Job {
//                     table_name: table.clone(),
//                     condition: JobCondition::WithString(condition.clone()),
//                     depth: 0,
//                 });
//             }
//         }
//     }
// }

struct Dumper {
    tables: HashMap<String, Table>,
}

impl Dumper {
    pub fn new() -> Self {
        Self {
            tables: HashMap::new(),
        }
    }

    fn export_chunk_conditions<T: Iterator<Item = Vec<ColumnHelper>>>(
        &mut self,
        chunk: T,
    ) -> (Vec<String>, Vec<Value>) {
        let (conditions, values) = chunk.fold(
            (Vec::<String>::new(), Vec::<Value>::new()),
            |mut acc, row| {
                let (names, row_values) = row.iter().fold(
                    (Vec::<&str>::new(), Vec::<Value>::new()),
                    |mut row_acc, c| {
                        row_acc.0.push(&c.name);
                        row_acc.1.push(c.value.0.clone());

                        row_acc
                    },
                );

                let condition = names
                    .iter()
                    .map(|name| format!("{} = ?", name))
                    .join(" AND ");

                acc.0.push(format!("({})", condition));
                acc.1.extend(row_values);

                acc
            },
        );
        (conditions, values)
    }

    fn export_chunk_rows<T: Queryable>(
        &mut self,
        table_name: &String,
        conditions: Vec<String>,
        conn: &mut T,
        values: Vec<Value>,
    ) {
        let query = format!(
            "SELECT * FROM {} WHERE {}",
            table_name,
            conditions.join(" OR ")
        );

        let result: Vec<Row> = conn.exec(query, values).unwrap();

        for (index, row) in result.iter().enumerate() {
            if index == 0 {
                let names = row
                    .columns_ref()
                    .iter()
                    .map(|c| format!("`{}`", c.name_str()))
                    .join(", ");

                print!("INSERT INTO {} ({}) VALUES ", table_name, names);
            }

            let values = row
                .columns_ref()
                .iter()
                .map(|c| format!("{}", row[c.name_str().as_ref()].as_sql(false)))
                .join(", ");

            if index == 0 {
                print!("({})", values);
            } else {
                print!(", ({})", values);
            }
        }

        println!(";");
    }

    pub fn export<T: Queryable>(
        &mut self,
        conn: &mut T,
        seen: HashMap<String, HashSet<Vec<ColumnHelper>>>,
    ) {
        let batch_size = 100;

        for (table_name, mut rows) in seen {
            let table = self.tables.get_mut(&table_name).unwrap();

            println!("{};", table.get_create_table_statement(conn));

            for chunk in &rows.drain().chunks(batch_size) {
                let (conditions, values) = self.export_chunk_conditions(chunk);

                self.export_chunk_rows(&table_name, conditions, conn, values);
            }
        }
    }

    pub fn find_rows<T: Queryable>(
        &mut self,
        conn: &mut T,
        jobs: Vec<Job>,
    ) -> HashMap<String, HashSet<Vec<ColumnHelper>>> {
        let mut queue = VecDeque::new();
        let mut seen: HashMap<String, HashSet<Vec<ColumnHelper>>> = HashMap::new();

        for job in jobs {
            queue.push_back(job);
        }

        while let Some(job) = queue.pop_front() {
            let row_cache = seen
                .entry(job.table_name.clone())
                .or_insert_with(HashSet::new);

            let (table, rows) = self.fetch_job_rows(conn, &job);
            for row in rows {
                // iterating on the primary key columns ensures we loop in the
                // same order every time
                let primary_key = table
                    .get_primary_key(conn)
                    .iter()
                    .map(|column_name| ColumnHelper {
                        name: column_name.clone(),
                        value: ValueHelper(row[column_name.as_ref()].clone()),
                    })
                    .collect();

                if !row_cache.insert(primary_key) {
                    continue;
                }

                if job.depth >= 0 {
                    for constraint in table.get_foreign_key_constraints(conn) {
                        let foreign_key = constraint
                            .columns
                            .iter()
                            .map(|column| {
                                let value = &row[column.column_name.as_ref()];

                                ColumnHelper {
                                    name: column.column_name.clone(),
                                    value: ValueHelper(value.clone()),
                                }
                            })
                            .collect();

                        let job = Job {
                            table_name: constraint.referenced_table_name.clone(),
                            condition: JobCondition::WithValues(foreign_key),
                            depth: job.depth + 1,
                        };

                        queue.push_back(job);
                    }
                }

                if job.depth <= 0 {
                    for constraint in table.get_reference_constraints(conn) {
                        let reference = constraint
                            .columns
                            .iter()
                            .map(|column| {
                                let value = &row[column.referenced_column_name.as_ref()];

                                ColumnHelper {
                                    name: column.column_name.clone(),
                                    value: ValueHelper(value.clone()),
                                }
                            })
                            .collect();

                        let job = Job {
                            table_name: constraint.table_name.clone(),
                            condition: JobCondition::WithValues(reference),
                            depth: job.depth - 1,
                        };

                        queue.push_back(job);
                    }
                }
            }
        }

        seen
    }

    fn fetch_job_rows<T: Queryable>(&mut self, conn: &mut T, job: &Job) -> (&mut Table, Vec<Row>) {
        let mut columns = HashSet::new();

        let table = self
            .tables
            .entry(job.table_name.clone())
            .or_insert_with(|| Table::new(job.table_name.clone()));

        for column in table.get_primary_key(conn) {
            columns.insert(column.clone());
        }

        for constraint in table.get_foreign_key_constraints(conn) {
            constraint.columns.iter().for_each(|c| {
                columns.insert(c.column_name.clone());
            });
        }

        let select_expr = itertools::join(columns, ", ");

        // all queries below use `exec` instead of `query` because they'll
        // return different types for the same column value. for example,
        // `query` may return a Value::Bytes("1") while `exec` gets us a
        // Value::Int(1)
        let rows: Vec<Row> = match &job.condition {
            JobCondition::FullTable => conn
                .exec(
                    format!("SELECT {} FROM {}", select_expr, job.table_name),
                    (),
                )
                .unwrap(),
            JobCondition::WithString(condition) => conn
                .exec(
                    format!(
                        "SELECT {} FROM {} WHERE {}",
                        select_expr, job.table_name, condition
                    ),
                    (),
                )
                .unwrap(),
            JobCondition::WithValues(values) => {
                let condition = values
                    .iter()
                    .map(|helper| format!("{} = ?", helper.name))
                    .collect::<Vec<String>>()
                    .join(" AND ");

                let values: Vec<&Value> = values.iter().map(|helper| &helper.value.0).collect();

                conn.exec(
                    format!(
                        "SELECT {} FROM {} WHERE {}",
                        select_expr, job.table_name, condition
                    ),
                    values,
                )
                .unwrap()
            }
        };

        (table, rows)
    }
}

fn main() {
    let args = Args::parse();

    let config: DumpConfig =
        serde_json::from_str(std::fs::read_to_string(args.config_file).unwrap().as_str()).unwrap();

    let opts = OptsBuilder::new()
        .ip_or_hostname(Some(config.host.clone()))
        .tcp_port(config.port.clone())
        .user(Some(config.username.clone()))
        .pass(Some(config.password.clone()))
        .db_name(Some(config.database.clone()));

    let pool = mysql::Pool::new(opts).unwrap();

    let mut conn = pool.get_conn().unwrap();

    let mut dumper = Dumper::new();
    let seen = dumper.find_rows(
        &mut conn,
        vec![
            Job {
                table_name: "one".to_string(),
                condition: JobCondition::WithString("id_one = 1".to_string()),
                depth: 0,
            },
            // Job {
            //     table_name: "five".to_string(),
            //     condition: JobCondition::FullTable,
            //     depth: 0,
            // },
            // Job {
            //     table_name: "five".to_string(),
            //     condition: JobCondition::FullTable,
            //     depth: 0,
            // },
            // Job {
            //     table_name: "five".to_string(),
            //     condition: JobCondition::FullTable,
            //     depth: 0,
            // },
            // Job {
            //     table_name: "five".to_string(),
            //     condition: JobCondition::WithValues(vec![("id_one".to_string(), Value::UInt(1))]),
            //     depth: 0,
            // },
            // Job {
            //     table_name: "multi_ref_five".to_string(),
            //     condition: JobCondition::FullTable,
            //     depth: 0,
            // },
        ],
    );

    dumper.export(&mut conn, seen);
}
