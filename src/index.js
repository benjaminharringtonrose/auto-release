const shell = require("shelljs");

async function sequentialExec() {
  try {
    await shell.exec("npm version patch");
    await shell.exec("./src/release.sh");
  } catch (e) {
    console.log(e);
  }
}

sequentialExec();
