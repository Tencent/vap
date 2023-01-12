import resolve from "rollup-plugin-node-resolve";
import babel from "rollup-plugin-babel";
import commonjs from 'rollup-plugin-commonjs';
import typescript from "rollup-plugin-typescript2";

const extensions = ['.js','.ts'];

export default [
  {
    input: "src/index.ts",
    output: {
      name: "Vap",
      file: "dist/vap.js",
      format: "umd"
    },
    plugins: [
      typescript({
        tsconfig: "rollup.tsconfig.json"
      }),
      resolve(), // so Rollup can find `ms`
      commonjs({
        include:'node_modules/**'
      }),
      babel({
        exclude: "node_modules/**",
        extensions,
        runtimeHelpers: true
      }),
    ]
  }
];
