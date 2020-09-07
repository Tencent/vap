import resolve from "rollup-plugin-node-resolve";
import babel from "rollup-plugin-babel";
import commonjs from 'rollup-plugin-commonjs';


export default [
    {
        input: "src/index.js",
        output: {
            name: "howLongUntilLunch",
            file: "dist/vap.js",
            format: "umd"
        },
        plugins: [
            resolve(), // so Rollup can find `ms`
            commonjs(),
            babel({
                exclude: "node_modules/**"
            }),
        ]
    }
];
