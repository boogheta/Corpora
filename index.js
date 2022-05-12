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

if (process.env.ADMIN_PASS) {
  global.settings.adminPass = process.env.ADMIN_PASS;
}

const router = require('./router');

require('./core/main')({
  router
});
