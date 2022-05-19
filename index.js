const path = require('path');
const packagejson = require('./package.json');
const base_settings = require('./settings_base.json');

global.appRoot = path.resolve(__dirname);
global.appInfos = {
  name: packagejson.name,
  productName: packagejson.productName,
  version: packagejson.version
};

let settings = base_settings;
try {
  const override_settings = require('./settings.json');
  Object.assign(settings, override_settings);
  console.log('INDEX / found override settings.json');
} catch (ex) {
  console.log('INDEX / didn’t find override settings');
}
global.settings = settings;

const environment_vars = {
  "ADMIN_PASS": {
    "key": "adminPass",
    "type": "str"
  },
  "SCPO": {
    "key": "scpo",
    "type": "bool"
  }
};
for (const env_var in environment_vars) {
  const env_val = process.env[env_var];
  if (env_val !== undefined) {
    if (environment_vars[env_var].type === "bool") {
      env_val = (env_val === "true");
    } else if (environment_vars[env_var].type === "int") {
      env_val = Number(env_val);
    }
    global.settings[environment_vars[env_var].key] = env_val;
  }
}

const router = require('./router');

require('./core/main')({
  router
});
