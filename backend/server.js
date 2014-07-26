////
// Requires & Vars
////

var jf = require('jsonfile');
var fs = require('fs');
var stripeLib = require("stripe");
var express = require('express');

var stripeKeyFile = './stripeKey.json';
var stripeKey;
var DB = {};
var stripe;
var app;

////
// Init
////

// Check for Stripe key
if (fs.existsSync(stripeKeyFile))
  stripeKey = jf.readFileSync(stripeKeyFile).data;
else {
  console.log("Please create Stripe key file with");
  console.log("contents: {data: <stripePrivateKey>}");
  return;
}

stripe = stripeLib(stripeKey);

app = express();
app.use(express.bodyParser());

fetchDB();

////
// Helpers
////

function error(err, res) {
  res.send({
            result: "error",
            error: err
           });
}

function fetchDB() {
  stripe.customers.list({ limit: 3 }, function(err, customers) {
    console.log(err);
    customers.data.forEach(function(c) {
      DB[c.description] = c.id;
      console.log("DB: %j", DB);
    });
  });
}

////
// HTTP Methods
////

app.post("/customers", function(req, res) {
  console.log("Got Post: %j", req.body);
  var tokenId = req.body.tokenId;
  var deviceId = req.body.deviceId;
  
  // Check params
  if (!tokenId || !deviceId) {
    error("Bad Params", res);
    return;
  }

  if (DB[deviceId]) {
    // Delete and create customer
    stripe.customers.del(DB[deviceId], function(err, confirmation) {
      if (err || !confirmation.deleted) error(err ? err : "Bad confirmation", res);
      else {
        stripe.customers.create({
          card: tokenId,
          description: deviceId
        }, function(err, customer) {
          if (err) error(err, res);
          else {
            DB[deviceId] = customer.id
            res.send({
              result: "success",
              customerId: customer.id
            });
          }
        });
      }
    });
  } else {
    // Create customer
    stripe.customers.create({
      card: tokenId,
      description: deviceId
    }, function(err, customer) {
      if (err) error(err, res);
      else {
        DB[deviceId] = customer.id
        res.send({
          result: "success",
          customerId: customer.id
        });
      }
    });
  }
});

app.post("/customers/delete", function(req, res) {
  console.log("Got Delete: %j", req.body);
  var deviceId = req.body.deviceId;
  
  // Check params
  if (!deviceId) {
    error("Bad Params", res);
    return;
  } else if (!DB[deviceId]) {
    error("DeviceId does not exist", res);
    return;
  } 

  stripe.customers.del(DB[deviceId], function(err, confirmation) {
    if (err || !confirmation.deleted) error(err ? err : "Bad confirmation", res);
    else {
      res.send({
        result: "success"
      });
    }
  });
});

app.post("/charge", function(req, res) {
  console.log("Got Post: %j", req.body);
  var customerId = req.body.customerId;
  var deviceId = req.body.deviceId;
  var episodeName = req.body.episodeName;

   // Check params
  if (!customerId || !deviceId || !episodeName) {
    error("Bad Params", res);
    return;
  } else if (!DB[deviceId]) {
    error("DeviceId does not exist", res);
    return;
  } else if (DB[deviceId] != customerId) {
    error("Wrong customer id", res);
    return;
  }

  stripe.charges.create({
      amount: 100,
      currency: "usd",
      customer: customerId,
      description: "Donation for " + episodeName
  }, function(err, charge) {
    if (err) error(err, res);
    else {
      res.send({
        result: "success"
      });
    }
  });
});

var server = app.listen(3000, function() {
      console.log('Listening on port %d', server.address().port);
});
