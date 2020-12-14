use std::io::prelude::*;
use std::net::TcpStream;
use std::net::TcpListener;
use std::fs;
use std::thread;
use std::time::Duration;
use mini_web_server::ThreadPool;
use std::time::{SystemTime, UNIX_EPOCH};

fn main() {
    let listener = TcpListener::bind("127.0.0.1:7878").unwrap();
    let pool = ThreadPool::new(4);

    for stream in listener.incoming() {
        let stream = stream.unwrap();
        pool.execute(||{
            handle_connection(stream);
        });
    }

    println!("Shutting down...");
}

fn handle_connection(mut stream: TcpStream) {
    let mut buffer = [0; 512];
    stream.read(&mut buffer).unwrap();

    let get = b"GET / HTTP/1.1\r\n";

    let status_line = "HTTP/1.1 200 OK\r\n";

    let contents = format!("{{\"timestamp_ms\": {}}}", get_epoch_ms());
    let content_type = "Content-Type: application/vnd.api+json\r\n";
    let response = format!("{}{}\r\n{}", status_line, content_type,contents);
    println!("response: {}", response);
    stream.write(response.as_bytes()).unwrap();
    stream.flush().unwrap();
}


fn get_epoch_ms() -> u128 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_millis()
}