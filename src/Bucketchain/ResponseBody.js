'use strict';

const Readable = require('stream').Readable;

exports.body = function(str) {
  return function() {
    const readable = new Readable();
    readable.push(str);
    readable.push(null);
    return readable;
  }
}

exports.empty = function() {
  const readable = new Readable();
  readable.push(null);
  return readable;
}
