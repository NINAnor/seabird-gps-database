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

use chrono::{DateTime, Duration, Utc};

fn main() {
    let args: Vec<String> = env::args().collect();
    let input_path = &args[1];
    let unparsed_file = fs::read_to_string(input_path).expect("Cannot read file");

    let identifier = Path::new(input_path).file_stem().unwrap().to_str().unwrap();

    let file = LoggerParser::parse(Rule::file, &unparsed_file)
        .expect("Cannot parse file")
        .next().unwrap();

    let mut header_missing = true;
    let mut pathtrack_definition = "";

    let mut frequency = Duration::milliseconds(0);
    let mut date = String::new();
    let mut time = String::new();
    let mut datetime = Utc::now();

    for file_pair in file.into_inner() {
        match file_pair.as_rule() {
            Rule::pathtrack_definition => {
                pathtrack_definition = file_pair.as_str();
            },
            Rule::frequency => {
                frequency = Duration::milliseconds(file_pair.as_str().parse().unwrap());
            },
            Rule::date => {
                date = file_pair.as_str().replace(" ", "0").replace("/", "-");
            },
            Rule::time => {
                time = file_pair.as_str().into();
            },
            Rule::csv_header_line => {
                header_missing = false;
                print!("filename");
                if !date.is_empty() {
                    print!(",timestamp");
                    datetime = format!("{}T{}Z", date, time).parse::<DateTime<Utc>>().unwrap();
                }
                for csv_header_line in file_pair.into_inner() {
                    match csv_header_line.as_rule() {
                        Rule::csv_header_cell => print!(",{}", csv_header_line.as_str().trim()),
                        _ => unreachable!(),
                    }
                }
                println!();
            },
            Rule::csv_line => {
                if header_missing {
                    if pathtrack_definition.starts_with("PathTrack Raw Pressure Data File") {
                        println!("filename,year,month,day,hour,minute,second,temperature,pressure_mbar,depth_m");
                    } else if pathtrack_definition.starts_with("PathTrack Archival Tracking System Results File") {
                        println!("filename,day,month,year,hour,minute,second,second_of_day,satellites,lat,lon,altitude,clock_offeset,accuracy,battery,unknown1,unknown2");
                    } else {
                        panic!();
                    }
                    header_missing = false;
                }
                print!("{}", identifier);
                if !date.is_empty() {
                    datetime += frequency;
                    print!(",{}", datetime.to_rfc3339());
                }
                for csv_line_pair in file_pair.into_inner() {
                    match csv_line_pair.as_rule() {
                        Rule::csv_cell => print!(",{}", csv_line_pair.as_str().trim()),
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
