// This script is written to decode zh-CN UTF-8 data converted into raw UTF-16 code points
// using JavaScript `String.fromCharCode`.

const fs = require("fs");

const input = fs.readFileSync(process.argv[2], "utf-8").trim().split("\n").join("").split("=").filter(x => x)
let out = "";
for(let i = 0; i < input.length; i += 2) {
  if(input[i] == "C2") {
    out += input[i + 1];
  } else if(input[i] == "C3" && input[i + 1][0] == "A") {
    out += "E" + input[i + 1][1];
  } else {
    throw new Error("bad");
  }
}

console.log(out);
