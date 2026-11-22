import type { Register } from 'claude-code'
import { linea } from './linea'

export const register: Register = on => {
  on('session.measure', async ($, e, next) => {
    $.ui.status(linea(await $.session.model(), e))
    return next(e)
  })
}
