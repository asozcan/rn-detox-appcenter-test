module.exports = {
  preset: 'react-native',
  cacheDirectory: './cache',
  moduleDirectories: ['node_modules', 'src'],
  testRegex: '(/__tests__/.*|' + '(\\.|' + '/)(test|spec))\\.(jsx?|tsx?)?$',
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
  coverageThreshold: {
    global: {
      statements: 80,
    },
  },
  transformIgnorePatterns: [
    '<rootDir>/node_modules/(?!(' +
      '@react-native|' +
      '@react-navigation|' +
      '@react-native-community|' +
      'react-native|' +
      'react-navigation-tabs|' +
      'react-native-screens|' +
      'redux-persist|' +
      ')/)',
  ],
};
