import { test, expect } from 'claude-code/testing'
import { linea } from './linea'

const ctx = (percent?: number) => ({ window: 200000, tokens: percent === undefined ? undefined : percent * 2000, percent })

test('muestra modelo, contexto, cuota y costo sin aviso', () => {
  const s = linea('claude-sonnet-5-5', { context: ctx(30), rateLimits: [{ kind: 'five_hour', percentUsed: 12 }], cost: { usd: 0.5 } })
  expect(s).toBe('Sonnet · ctx 30% · 5h 12% · $0.50')
})

test('avisa /clear desde 60% y relevo desde 85%', () => {
  expect(linea('claude-opus-5-5', { context: ctx(60), rateLimits: [] })).toContain('/clear')
  const lleno = linea('claude-opus-5-5', { context: ctx(90), rateLimits: [] })
  expect(lleno).toContain('relevo')
  expect(lleno).not.toContain('/clear')
})

test('avisa cuota de 5 horas alta y tolera datos faltantes', () => {
  expect(linea('claude-haiku-5-5', { context: ctx(), rateLimits: [{ kind: 'five_hour', percentUsed: 85 }] })).toBe('Haiku · 5h 85% · ⚠ cuota 5h: delega a OpenCode/agy')
})
