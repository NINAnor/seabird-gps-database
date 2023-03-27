extern crate pest;
#[macro_use]
extern crate pest_derive;

use pest::Parser;

#[derive(Parser)]
#[grammar = "logger.pest"]
struct LoggerParser;

use std::env;
use std::fs;
use std::path::Path;

fn main() {
    let args: Vec<String> = env::args().collect();
    let input_path = &args[1];
    let unparsed_file = fs::read_to_string(input_path).expect("Cannot read file");

    let identifier = Path::new(input_path).file_stem().unwrap().to_str().unwrap();

    let file = LoggerParser::parse(Rule::file, &unparsed_file)
        .expect("Cannot parse file")
        .next().unwrap();

    for file_pair in file.into_inner() {
        match file_pair.as_rule() {
            Rule::csv_line => {
                print!("{}", identifier);
                for csv_line_pair in file_pair.into_inner() {
                    match csv_line_pair.as_rule() {
                        Rule::csv_cell => print!(",{}", csv_line_pair.as_str()),
                        _ => unreachable!(),
                    }
                }
                println!();
            },
            Rule::EOI => (),
            _ => unreachable!(),
        }
    }
}
