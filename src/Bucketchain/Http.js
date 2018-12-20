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

exports._responseHeader = function(res) {
  return function(name) {
    return res.getHeader(name);
  }
}

exports._responseHeaders = function(res) {
  return function(name) {
    return res.getHeader(name) || [];
  }
}

exports._statusCode = function(res) {
  return res.statusCode;
}
