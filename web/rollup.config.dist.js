import resolve from "rollup-plugin-node-resolve";
import babel from "rollup-plugin-babel";
import uglify from "rollup-plugin-uglify";
import commonjs from 'rollup-plugin-commonjs';


export default [
    {
        input: "src/index.js",
        output: {
            name: "howLongUntilLunch",
            file: "dist/vap.min.js",
            format: "umd"
        },
        plugins: [
            resolve(), // so Rollup can find `ms`
            commonjs(),
            babel({
                exclude: "node_modules/**"
            }),
            uglify({
                compress: {
                    drop_console: true,
                    drop_debugger: true
                }
            })
        ]
    }
];
