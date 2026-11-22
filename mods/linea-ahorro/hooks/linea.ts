import type { SessionMeasureInput } from 'claude-code'

// Umbrales de contexto: desde AVISO conviene cerrar el tema; desde LLENO, relevo ya.
export const AVISO = 60
export const LLENO = 85
const CUOTA = 80

export function corto(model: string): string {
  const m = model.toLowerCase()
  for (const n of ['opus', 'sonnet', 'haiku', 'fable']) if (m.includes(n)) return n[0].toUpperCase() + n.slice(1)
  return model
}

export function linea(model: string, u: Pick<SessionMeasureInput, 'context' | 'rateLimits' | 'cost'>): string {
  const partes = [corto(model)]
  const pct = u.context.percent
  if (pct !== undefined) partes.push(`ctx ${pct}%`)
  const cinco = u.rateLimits.find(r => r.kind === 'five_hour')
  if (cinco) partes.push(`5h ${cinco.percentUsed}%`)
  if (u.cost) partes.push(`$${u.cost.usd.toFixed(2)}`)
  if (pct !== undefined && pct >= LLENO) partes.push('⚠ contexto lleno: di "relevo"')
  else if (pct !== undefined && pct >= AVISO) partes.push('💡 tema nuevo → /clear')
  if (cinco && cinco.percentUsed >= CUOTA) partes.push('⚠ cuota 5h: delega a OpenCode/agy')
  return partes.join(' · ')
}
