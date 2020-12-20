var execSh = require("../");
console.log("here")
// run interactive bash shell
() => {
  execSh("./release.sh", { cwd: "/src" }, function (err) {
    if (err) {
      console.log("Exit code: ", err.code);
      return;
    }
  });
};
