'use strict';

import { Readable } from "stream";

export function body(str) {
  return function() {
    const readable = new Readable();
    readable.push(str);
    readable.push(null);
    return readable;
  }
}

export function empty() {
  const readable = new Readable();
  readable.push(null);
  return readable;
}
