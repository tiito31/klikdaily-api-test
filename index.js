const express = require("express");
const bodyParser = require("body-parser");
const app = express();
const mysql = require("mysql");

// parse application/json
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// create database connection
const conn = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "restful_db",
});

// connect to db
conn.connect((err) => {
  if (err) throw err;
  console.log("Mysql Connected ...");
});

// Get all
app.get("/klikdaily/stocks", (req, res) => {
  let sql =
    "select location.id as 'id', location.name as 'location', product.qty as 'quantity', product.name as 'product' from location, product where location.id = product.location_id";
  let query = conn.query(sql, (err, results) => {
    if (err) throw err;
    res.send(
      JSON.stringify({
        status_code: 200,
        status_message: "Success",
        stocks: results,
      })
    );
  });
});

let getProduct = "SELECT location_id, name from product";

conn.query(getProduct, function (err, rows) {
  if (err) throw err;
  else {
    setValue(rows);
  }
});

var result_arr = [];

function setValue(value) {
  // for (var key in value) {
  //   // result_id = value[key].location_id;
  //   // result_name = value[key].name;

  // }
  result_arr = value;
}

// adjust data
app.post("/klikdaily/adjusment/", (req, res) => {
  for (var key in req.body) {
    if (req.body.hasOwnProperty(key)) {
      var data = {
        location_id: req.body[key].location_id,
        name: req.body[key].product,
        qty: req.body[key].adjusment,
      };

      for (var i in result_arr) {
        if (
          data.location_id == result_arr[i].location_id &&
          data.name == result_arr[i].name
        ) {
          let sql = "INSERT INTO product SET ?";
          var query = conn.query(sql, data, (err, result) => {
            if (err) throw err;
            console.log(
              +result.affectedRows + "Data inserted Successfully ..."
            );
          });
        }
      }
    }
  }
  let dt = conn.query("SELECT * from stock", (err, results) => {
    if (err) throw err;
    res.send(
      JSON.stringify({
        status_code: 200,
        status_messages: results.status,
        requests: data.lenght,
        adjusted: results.count,
        results: results,
      })
    );
  });
});

// show log
app.get("/klikdaily/logs/:location_id", (req, res) => {
  let sql = "Select * from stock where location_id =" + req.params.location_id;
  let query = conn.query(sql, (err, results) => {
    if (err) throw err;
    res.status(200).send(
      JSON.stringify({
        status: "Success, logs found",
        location_id: results.location_id,
        location_name: results.location_name,
        product: results.product,
        current_qty: results.quantity,
        logs: results,
      })
    );
  });
});

// Server listening
app.listen(3000, () => {
  console.log("Server started on port 3000 ...");
});
