module.exports = {
    root: true,
    env: {
        browser: true,
    },
    parserOptions: {
        parser: '@typescript-eslint/parser',
        ecmaVersion: 'latest',
        sourceType: 'module',
    },
    extends: [
        'eslint:recommended',
        'plugin:@typescript-eslint/recommended',
        'plugin:prettier/recommended', // @extends prettier
    ],
    plugins: ['@typescript-eslint', 'prettier'],
};
