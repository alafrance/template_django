const path = require('path');

module.exports = {
  entry: {
    index : './assets/js/index.js',
  },
  output: {
    filename: '[name].js', 
    path: path.resolve(__dirname, './static/js'),
  },
  module: {
    rules: [
      {
        test: /\.css$/i,
        use: ["style-loader", "css-loader", 'postcss-loader'],
      },
    ],
  },
};