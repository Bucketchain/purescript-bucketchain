'use strict';

export function _setRequestURL(req) {
  return function(url) {
    return function() {
      req.originalUrl = req.originalUrl || req.url;
      req.url = url;
      return {};
    }
  }
}

export function _requestOriginalURL(req) {
  return req.originalUrl || req.url;
}

export function _responseHeader(res) {
  return function(name) {
    return res.getHeader(name);
  }
}

export function _responseHeaders(res) {
  return function(name) {
    return res.getHeader(name) || [];
  }
}

export function _statusCode(res) {
  return res.statusCode;
}
