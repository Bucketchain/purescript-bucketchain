'use strict';

exports._setRequestURL = function(req) {
  return function(url) {
    return function() {
      req.originalUrl = req.originalUrl || req.url;
      req.url = url;
      return {};
    }
  }
}

exports._requestOriginalURL = function(req) {
  return req.originalUrl || req.url;
}

exports._responseHeaders = function(res) {
  return res.getHeaders();
}

exports._statusCode = function(res) {
  return res.statusCode;
}
