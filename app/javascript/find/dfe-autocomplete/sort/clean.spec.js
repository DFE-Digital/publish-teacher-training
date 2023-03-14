import clean from './clean'

describe('clean', () => {
  it('returns cleaned', () => {
    expect(clean(' A\'b’De.F,g"H/i#J!k$L%m^N&o*P;q:R{s}T=u-v_X`y~Z(0)12 3  4 567 89 ')).toEqual('abde f g h i j k l m n o p q r s t u v x y z 0 12 3  4 567 89')
  })

  it('trims', () => {
    expect(clean(' az 0   ')).toEqual('az 0')
  })

  it('lowercase', () => {
    expect(clean('AZ 0')).toEqual('az 0')
  })

  it('remove chars', () => {
    expect(clean('a\'’z 0')).toEqual('az 0')
  })

  it('replace chars', () => {
    expect(clean('a.,"/#!$%^&*;:{}=-_`~()’z 0')).toEqual('a                      z 0')
  })
})
