import propertyGroups from 'stylelint-config-recess-order/groups'

/** @type {import("stylelint").Config} */
export default {
  extends: ['stylelint-config-gds/scss', 'stylelint-config-recess-order'],
  plugins: ['stylelint-order'],
  rules: {
    // Configure the rule manually.
    'order/properties-order': propertyGroups.map((group) => ({
      ...group,
      emptyLineBefore: 'always',
      noEmptyLineBetween: true
    })),
    'value-keyword-case': [
      'lower',
      {
        camelCaseSvgKeywords: true
      }
    ],
    'scss/at-extend-no-missing-placeholder': null,
    // `body:not(.js-enabled)` and BEM `&__element` nesting both trip this
    // rule, which reads the resolved leading segment as a type selector.
    // Type qualifying by id or attribute is still reported.
    'selector-no-qualifying-type': [true, { ignore: ['class'] }]
  }
}
