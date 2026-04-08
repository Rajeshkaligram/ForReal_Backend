const mix = require('laravel-mix');

/*
 |--------------------------------------------------------------------------
 | Mix Asset Management
 |--------------------------------------------------------------------------
 |
 | Mix provides a clean, fluent API for defining some Webpack build steps
 | for your Laravel application. By default, we are compiling the Sass
 | file for the application as well as bundling up all the JS files.
 |
 */

mix.js('resources/assets/js/app.js', 'public/js')
   .sass('resources/assets/sass/app.scss', 'public/css')
   .options({
       processCssUrls: false
   })
   .webpackConfig({
       stats: {
           children: true
       },
       infrastructureLogging: {
           level: 'error'
       },
       devServer: {
           client: {
               logging: {
                   level: 'error'
               }
           }
       },
       // Disable progress plugin to fix webpack-cli 4.x compatibility
       plugins: [
           new (require('webpack')).ProgressPlugin(false)
       ]
   });

// Disable progress plugin to avoid webpack-cli compatibility issues
if (mix.inProduction()) {
    mix.disableNotifications();
}
