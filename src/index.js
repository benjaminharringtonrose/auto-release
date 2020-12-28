const shell = require("shelljs");

async function sequentialExec() {
  try {
    await shell.exec("yarn version");
    await shell.exec("./src/release.sh");
  } catch (e) {
    console.log(e);
  }
}

sequentialExec();
