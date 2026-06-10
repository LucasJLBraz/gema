import { useState, useEffect, useRef } from "react";

// ─── TOKENS ─────────────────────────────────────────────────────────────────
const T = {
  light: {
    bg: "#F6F4F0", surface: "#FFFFFF", surfaceVar: "#EBE3D8", surfaceEmph: "#F0EDE8",
    primary: "#B3700C", primaryCont: "#FDDEA3", onPrimCont: "#3A1F00",
    secondary: "#665940", secondaryCont: "#F2E5CC", onSecCont: "#221A0A",
    text: "#1A1814", textSub: "#4A3F32", textDis: "#9A8E80",
    outline: "#BEB0A0", outlineVar: "#E6DDD2", divider: "#EBE3D8",
    error: "#B3261E", errorCont: "#FFDAD6", onErrCont: "#410002",
    success: "#386A20", successCont: "#C2F099",
  },
  dark: {
    bg: "#131110", surface: "#1C1916", surfaceVar: "#282320", surfaceEmph: "#222018",
    primary: "#F4BA52", primaryCont: "#472F00", onPrimCont: "#FDDEA3",
    secondary: "#CDB998", secondaryCont: "#3A2E1C", onSecCont: "#F2E5CC",
    text: "#EDE4D8", textSub: "#A8957E", textDis: "#5A5048",
    outline: "#38302A", outlineVar: "#2A2420", divider: "#282320",
    error: "#FFB4AB", errorCont: "#93000A", onErrCont: "#FFDAD6",
    success: "#86C278", successCont: "#1A4A0A",
  },
};

const C = {
  light: { kcal: "#B3700C", protein: "#2E8B7A", carbs: "#5C7EB0", fat: "#B86840" },
  dark:  { kcal: "#F4BA52", protein: "#5EC9B8", carbs: "#87AEDC", fat: "#E4916A" },
};

// ─── STORYBOOK CHROME TOKENS (sempre escuro, independente do modo) ──────────
const SB = {
  bg:      "#0F0E0C",
  sidebar: "#161412",
  border:  "#262220",
  text:    "#C8BFB4",
  textSub: "#6A5E52",
  active:  "#1E1A16",
  accent:  "#F4BA52",
};

// ─── HELPERS ────────────────────────────────────────────────────────────────
const font = "'Plus Jakarta Sans', system-ui, sans-serif";
const mono = "'DM Mono', 'Courier New', monospace";

const Divider = ({ p }) => (
  <div style={{ height: "1px", backgroundColor: p.divider, margin: "16px 0" }} />
);

const SectionLabel = ({ children, p }) => (
  <p style={{
    margin: "0 0 14px 0", fontSize: "10px", letterSpacing: "2px",
    textTransform: "uppercase", color: p.textSub, fontWeight: 600, fontFamily: font,
  }}>{children}</p>
);

const StoryCard = ({ title, hint, children, p }) => (
  <div style={{ marginBottom: "28px" }}>
    {title && (
      <div style={{ marginBottom: "10px" }}>
        <span style={{ fontSize: "12px", fontWeight: 700, color: p.textSub, fontFamily: font }}>{title}</span>
        {hint && <span style={{ fontSize: "11px", color: p.textDis, marginLeft: "8px", fontFamily: mono }}>{hint}</span>}
      </div>
    )}
    <div style={{
      backgroundColor: p.surface, borderRadius: "16px", padding: "20px",
      border: `1px solid ${p.outlineVar}`,
    }}>
      {children}
    </div>
  </div>
);

const Row = ({ children, gap = 10, wrap = true }) => (
  <div style={{ display: "flex", gap, flexWrap: wrap ? "wrap" : "nowrap", alignItems: "center" }}>
    {children}
  </div>
);

// ─── PROGRESS RING (componente reutilizável) ─────────────────────────────────
function Ring({ pct = 0.72, size = 130, strokeW = 10, p, isDark, label, sublabel }) {
  const R = (size - strokeW * 2) / 2;
  const circ = 2 * Math.PI * R;
  const cx = size / 2, cy = size / 2;
  const id = `rg-${size}-${isDark ? "d" : "l"}`;
  return (
    <div style={{ position: "relative", width: size, height: size, flexShrink: 0 }}>
      <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
        <defs>
          <linearGradient id={id} x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%"   stopColor={isDark ? "#FFD780" : "#F5A820"} />
            <stop offset="100%" stopColor={isDark ? "#D4820A" : "#7A4200"} />
          </linearGradient>
        </defs>
        <circle cx={cx} cy={cy} r={R} fill="none" stroke={p.surfaceVar} strokeWidth={strokeW} />
        {pct > 0 && (
          <circle cx={cx} cy={cy} r={R} fill="none"
            stroke={`url(#${id})`} strokeWidth={strokeW}
            strokeDasharray={circ} strokeDashoffset={circ * (1 - Math.min(pct, 1))}
            strokeLinecap="round" transform={`rotate(-90 ${cx} ${cy})`}
          />
        )}
      </svg>
      <div style={{
        position: "absolute", inset: 0, display: "flex",
        flexDirection: "column", alignItems: "center", justifyContent: "center",
      }}>
        {label && <span style={{ fontSize: size * 0.16, fontWeight: 800, color: p.text, letterSpacing: "-0.04em", lineHeight: 1, fontFamily: font }}>{label}</span>}
        {sublabel && <span style={{ fontSize: size * 0.085, color: p.textSub, marginTop: 3, fontFamily: font }}>{sublabel}</span>}
        <span style={{ fontSize: size * 0.09, color: p.primary, fontWeight: 700, marginTop: 2, fontFamily: font }}>{Math.round(pct * 100)}%</span>
      </div>
    </div>
  );
}

// ─── STORY: COLORS ───────────────────────────────────────────────────────────
function StoryColors({ p, c, isDark }) {
  const swatches = [
    { group: "Marca", items: [
      { n: "Primary",       v: p.primary,     text: isDark ? "#1A1814" : "#fff" },
      { n: "P. Container",  v: p.primaryCont, text: p.onPrimCont },
      { n: "Secondary",     v: p.secondary,   text: isDark ? "#1A1814" : "#fff" },
      { n: "S. Container",  v: p.secondaryCont,text: p.onSecCont },
    ]},
    { group: "Superfícies", items: [
      { n: "Background",    v: p.bg,          text: p.textSub },
      { n: "Surface",       v: p.surface,     text: p.textSub },
      { n: "Surf. Variant", v: p.surfaceVar,  text: p.textSub },
      { n: "Surf. Emph.",   v: p.surfaceEmph, text: p.textSub },
    ]},
    { group: "Texto & Estrutura", items: [
      { n: "Text",          v: p.text,        text: isDark ? "#131110" : "#fff" },
      { n: "Text Sub",      v: p.textSub,     text: isDark ? "#131110" : "#fff" },
      { n: "Disabled",      v: p.textDis,     text: isDark ? "#131110" : "#fff" },
      { n: "Outline",       v: p.outline,     text: isDark ? "#131110" : "#fff" },
    ]},
    { group: "Dados", items: [
      { n: "Kcal",    v: c.kcal,    text: "#fff" },
      { n: "Proteína",v: c.protein, text: "#fff" },
      { n: "Carbos",  v: c.carbs,   text: "#fff" },
      { n: "Gordura", v: c.fat,     text: "#fff" },
    ]},
    { group: "Semântico", items: [
      { n: "Error",         v: p.error,       text: isDark ? "#131110" : "#fff" },
      { n: "Error Cont.",   v: p.errorCont,   text: p.onErrCont },
      { n: "Success",       v: p.success,     text: "#fff" },
      { n: "Success Cont.", v: p.successCont, text: p.success },
    ]},
  ];
  return (
    <div>
      {swatches.map(({ group, items }) => (
        <div key={group} style={{ marginBottom: "24px" }}>
          <SectionLabel p={p}>{group}</SectionLabel>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(4, 1fr)", gap: "10px" }}>
            {items.map(({ n, v, text }) => (
              <div key={n}>
                <div style={{
                  height: "60px", borderRadius: "12px", backgroundColor: v, marginBottom: "6px",
                  border: `1px solid rgba(${isDark ? "255,255,255,0.05" : "0,0,0,0.06"})`,
                  display: "flex", alignItems: "flex-end", padding: "6px 7px",
                }}>
                  <span style={{ fontSize: "8px", fontFamily: mono, color: text, opacity: 0.85 }}>{v}</span>
                </div>
                <p style={{ margin: 0, fontSize: "10px", color: p.textSub, fontWeight: 500 }}>{n}</p>
              </div>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}

// ─── STORY: TYPOGRAPHY ───────────────────────────────────────────────────────
function StoryTypography({ p }) {
  const scale = [
    { name: "Display",    size: 32, weight: 800, tracking: "-1.2px",  sample: "2.050 kcal",           note: "Números grandes, home screen" },
    { name: "Headline",   size: 22, weight: 700, tracking: "-0.6px",  sample: "Análise de Progresso",  note: "Títulos de seção" },
    { name: "Title",      size: 17, weight: 600, tracking: "-0.3px",  sample: "Meta provável: 12–19 set", note: "Cards, subtítulos" },
    { name: "Body",       size: 14, weight: 400, tracking: "0",       sample: "Tendência dos últimos 21 dias indica déficit médio de 420 kcal/dia.", note: "Texto corrido" },
    { name: "Label",      size: 12, weight: 600, tracking: "0",       sample: "Registrar refeição",   note: "Botões, chips, ações" },
    { name: "Caption",    size: 11, weight: 500, tracking: "1.6px",   sample: "MAIS CONSUMIDOS",       note: "Labels de seção — uppercase" },
    { name: "Micro",      size: 10, weight: 500, tracking: "1.8px",   sample: "PALETA DE CORES",       note: "Eyebrows, metadados" },
    { name: "Data (mono)",size: 13, weight: 500, tracking: "0",       sample: "#B3700C  ·  1.480 kcal", note: "Tokens, hex, dados brutos", mono: true },
  ];
  return (
    <div>
      {scale.map(({ name, size, weight, tracking, sample, note, mono: isMono }) => (
        <div key={name}>
          <div style={{ display: "flex", alignItems: "baseline", justifyContent: "space-between", gap: 8 }}>
            <p style={{
              margin: "10px 0 4px",
              fontSize: size,
              fontWeight: weight,
              letterSpacing: tracking,
              color: p.text,
              fontFamily: isMono ? mono : font,
              lineHeight: 1.3,
              flex: 1,
            }}>{sample}</p>
          </div>
          <div style={{ display: "flex", gap: 12, marginBottom: "4px" }}>
            <span style={{ fontSize: "10px", fontFamily: mono, color: p.textDis }}>{weight} · {size}px · {tracking || "0"}</span>
            <span style={{ fontSize: "10px", color: p.textSub }}>— {note}</span>
          </div>
          <div style={{ height: "1px", backgroundColor: p.divider }} />
        </div>
      ))}
    </div>
  );
}

// ─── STORY: BUTTONS ──────────────────────────────────────────────────────────
function StoryButtons({ p, isDark }) {
  const btnBase = { fontFamily: font, cursor: "pointer", border: "none", fontWeight: 700, fontSize: "13px", display: "inline-flex", alignItems: "center", gap: "6px", transition: "opacity 0.15s" };
  const variants = [
    {
      name: "Filled — ação primária",
      hint: "FAB, CTA principal",
      buttons: [
        { label: "📷 Registrar", style: { ...btnBase, background: `linear-gradient(135deg, ${isDark?"#FFD780":"#E08A10"}, ${p.primary})`, color: isDark ? "#2A1800" : "#fff", padding: "13px 22px", borderRadius: "16px", boxShadow: `0 4px 18px ${p.primary}50` } },
        { label: "Salvar", style: { ...btnBase, backgroundColor: p.primary, color: isDark ? "#2A1800" : "#fff", padding: "12px 20px", borderRadius: "14px" } },
        { label: "Salvar", disabled: true, style: { ...btnBase, backgroundColor: p.surfaceVar, color: p.textDis, padding: "12px 20px", borderRadius: "14px", cursor: "not-allowed" } },
      ],
    },
    {
      name: "Tonal — ação secundária",
      hint: "Chips de ação, secondary CTA",
      buttons: [
        { label: "⚡ Quick Add", style: { ...btnBase, backgroundColor: p.primaryCont, color: p.onPrimCont, padding: "11px 16px", borderRadius: "13px" } },
        { label: "📦 Barcode",   style: { ...btnBase, backgroundColor: p.primaryCont, color: p.onPrimCont, padding: "11px 16px", borderRadius: "13px" } },
        { label: "Reprocessar",  style: { ...btnBase, backgroundColor: p.secondaryCont, color: p.onSecCont, padding: "11px 16px", borderRadius: "13px" } },
      ],
    },
    {
      name: "Outlined — ação terciária",
      hint: "Cancelar, voltar, alternativas",
      buttons: [
        { label: "Cancelar",      style: { ...btnBase, backgroundColor: "transparent", color: p.text, border: `1.5px solid ${p.outline}`, padding: "11px 16px", borderRadius: "13px" } },
        { label: "Manter edição", style: { ...btnBase, backgroundColor: "transparent", color: p.primary, border: `1.5px solid ${p.primary}`, padding: "11px 16px", borderRadius: "13px" } },
      ],
    },
    {
      name: "Destructive — erro / remover",
      hint: "Deletar refeição, redefinir meta",
      buttons: [
        { label: "Remover refeição", style: { ...btnBase, backgroundColor: p.errorCont, color: p.onErrCont, padding: "11px 16px", borderRadius: "13px" } },
        { label: "Descartar",        style: { ...btnBase, backgroundColor: "transparent", color: p.error, border: `1.5px solid ${p.error}`, padding: "11px 16px", borderRadius: "13px" } },
      ],
    },
  ];
  return (
    <>
      {variants.map(({ name, hint, buttons }) => (
        <StoryCard key={name} title={name} hint={hint} p={p}>
          <Row>
            {buttons.map((b, i) => (
              <button key={i} style={b.style} disabled={b.disabled}>{b.label}</button>
            ))}
          </Row>
        </StoryCard>
      ))}
    </>
  );
}

// ─── STORY: CHIPS ────────────────────────────────────────────────────────────
function StoryChips({ p }) {
  const [filters, setFilters] = useState({ "7d": true, "14d": false, "30d": false });
  const [macros, setMacros] = useState({ proteína: true, carbos: true, gordura: false });
  const toggle = (obj, setObj, k) => setObj(prev => ({ ...prev, [k]: !prev[k] }));
  const chipBase = { fontFamily: font, cursor: "pointer", fontSize: "12px", fontWeight: 600, padding: "8px 14px", borderRadius: "20px", border: "none", transition: "all 0.15s" };
  return (
    <>
      <StoryCard title="Filter chips — período" p={p}>
        <Row>
          {Object.entries(filters).map(([k, on]) => (
            <button key={k} onClick={() => toggle(filters, setFilters, k)} style={{ ...chipBase,
              backgroundColor: on ? p.primaryCont : p.surfaceVar,
              color: on ? p.onPrimCont : p.textSub,
              border: on ? `1.5px solid ${p.primary}40` : "1.5px solid transparent",
            }}>
              {on && "✓ "}{k}
            </button>
          ))}
        </Row>
      </StoryCard>
      <StoryCard title="Filter chips — macros" p={p}>
        <Row>
          {Object.entries(macros).map(([k, on]) => (
            <button key={k} onClick={() => toggle(macros, setMacros, k)} style={{ ...chipBase,
              backgroundColor: on ? p.primaryCont : p.surfaceVar,
              color: on ? p.onPrimCont : p.textSub,
            }}>{on ? "✓ " : ""}{k}</button>
          ))}
        </Row>
      </StoryCard>
      <StoryCard title="Input chip — alimento adicionado" hint="Quick Add" p={p}>
        <Row>
          {["🍚 Arroz branco · 200g", "🍗 Frango grelhado · 150g", "🥚 Ovo cozido · 60g"].map(label => (
            <div key={label} style={{
              display: "inline-flex", alignItems: "center", gap: "6px",
              backgroundColor: p.surfaceVar, borderRadius: "20px",
              padding: "7px 12px", fontSize: "12px", color: p.textSub, fontFamily: font,
            }}>
              {label}
              <span style={{ color: p.textDis, fontSize: "14px", cursor: "pointer", lineHeight: 1 }}>×</span>
            </div>
          ))}
        </Row>
      </StoryCard>
    </>
  );
}

// ─── STORY: PROGRESS RING ────────────────────────────────────────────────────
function StoryRing({ p, isDark }) {
  const variants = [
    { pct: 0,    label: "0",     sublabel: "de 2.050 kcal", caption: "Início do dia" },
    { pct: 0.42, label: "860",   sublabel: "de 2.050 kcal", caption: "Manhã" },
    { pct: 0.72, label: "1.480", sublabel: "de 2.050 kcal", caption: "Tarde" },
    { pct: 1.04, label: "2.130", sublabel: "de 2.050 kcal", caption: "Acima da meta" },
  ];
  return (
    <>
      <StoryCard title="Variantes de preenchimento" hint="stroke-dashoffset animado" p={p}>
        <div style={{ display: "flex", gap: 24, flexWrap: "wrap", justifyContent: "center" }}>
          {variants.map(({ pct, label, sublabel, caption }) => (
            <div key={caption} style={{ textAlign: "center" }}>
              <Ring pct={pct} size={116} strokeW={9} p={p} isDark={isDark} label={label} sublabel={sublabel} />
              <p style={{ margin: "8px 0 0", fontSize: "11px", color: p.textSub, fontFamily: font }}>{caption}</p>
            </div>
          ))}
        </div>
      </StoryCard>
      <StoryCard title="Tamanhos" hint="size prop" p={p}>
        <Row gap={20} wrap={false}>
          {[160, 120, 88, 60].map(size => (
            <Ring key={size} pct={0.68} size={size} strokeW={Math.round(size * 0.072)} p={p} isDark={isDark}
              label={size >= 88 ? "1.480" : undefined} sublabel={size >= 120 ? "de 2.050 kcal" : undefined} />
          ))}
        </Row>
      </StoryCard>
    </>
  );
}

// ─── STORY: PROGRESS BAR ─────────────────────────────────────────────────────
function StoryProgressBar({ p, c }) {
  const macros = [
    { label: "Proteína",    val: "92g", meta: "130g", pct: 0.71, color: c.protein },
    { label: "Carboidratos",val: "150g",meta: "210g", pct: 0.71, color: c.carbs },
    { label: "Gordura",     val: "48g", meta: "68g",  pct: 0.71, color: c.fat },
    { label: "Proteína",    val: "138g",meta: "130g", pct: 1.06, color: c.protein },
  ];
  const MacroBar = ({ label, val, meta, pct, color }) => (
    <div style={{ marginBottom: "12px" }}>
      <div style={{ display: "flex", justifyContent: "space-between", marginBottom: "5px" }}>
        <span style={{ fontSize: "12px", color: p.textSub, fontFamily: font, fontWeight: 500 }}>{label}</span>
        <span style={{ fontSize: "12px", fontWeight: 700, color: p.text, fontFamily: font }}>
          {val} <span style={{ fontWeight: 400, color: p.textSub }}>/ {meta}</span>
        </span>
      </div>
      <div style={{ height: "6px", borderRadius: "3px", backgroundColor: p.surfaceVar, overflow: "visible", position: "relative" }}>
        <div style={{
          height: "100%", width: `${Math.min(pct, 1) * 100}%`, borderRadius: "3px",
          backgroundColor: pct > 1 ? p.primary : color, transition: "width 0.5s ease",
          maxWidth: "100%",
        }} />
        {pct > 1 && (
          <span style={{
            position: "absolute", right: 0, top: "50%", transform: "translateY(-50%)",
            fontSize: "10px", color: p.primary, fontWeight: 700, fontFamily: font,
          }}>+{Math.round((pct - 1) * 100)}%</span>
        )}
      </div>
    </div>
  );
  return (
    <>
      <StoryCard title="Barras de macro" hint="variant: normal, over-target" p={p}>
        {macros.map((m, i) => <MacroBar key={i} {...m} />)}
      </StoryCard>
      <StoryCard title="Barra de progresso genérica" hint="variant: slim, full-width" p={p}>
        {[0.25, 0.6, 0.88, 1.0].map(pct => (
          <div key={pct} style={{ marginBottom: "10px" }}>
            <div style={{ display: "flex", justifyContent: "space-between", marginBottom: "4px" }}>
              <span style={{ fontSize: "11px", color: p.textSub, fontFamily: font }}>{Math.round(pct * 2050)} kcal</span>
              <span style={{ fontSize: "11px", color: p.textSub, fontFamily: font }}>{Math.round(pct * 100)}%</span>
            </div>
            <div style={{ height: "4px", borderRadius: "2px", backgroundColor: p.surfaceVar }}>
              <div style={{ height: "100%", width: `${pct * 100}%`, borderRadius: "2px", backgroundColor: p.primary }} />
            </div>
          </div>
        ))}
      </StoryCard>
    </>
  );
}

// ─── STORY: XP BADGE ─────────────────────────────────────────────────────────
function StoryBadge({ p, c }) {
  const events = [
    { icon: "🍽️", label: "Todas as refeições registradas", xp: "+100 XP", color: p.primaryCont, text: p.onPrimCont },
    { icon: "💪", label: "Meta de proteína batida",         xp: "+50 XP",  color: p.successCont, text: p.success },
    { icon: "⚖️", label: "Pesagem registrada",              xp: "+30 XP",  color: p.secondaryCont, text: p.onSecCont },
    { icon: "🌊", label: "Meta de água batida",             xp: "+20 XP",  color: p.secondaryCont, text: p.onSecCont },
    { icon: "🎯", label: "Cheat planejado",                 xp: "+10 XP",  color: p.surfaceVar,  text: p.textSub },
  ];
  return (
    <>
      <StoryCard title="Nível e XP total" p={p}>
        <div style={{ display: "flex", gap: 16, flexWrap: "wrap", alignItems: "center" }}>
          {[{ lvl: 1, xp: 180 }, { lvl: 4, xp: 1230 }, { lvl: 9, xp: 7840 }, { lvl: 16, xp: 25600 }].map(({ lvl, xp }) => (
            <div key={lvl} style={{
              display: "flex", flexDirection: "column", alignItems: "center",
              backgroundColor: p.primaryCont, borderRadius: "14px", padding: "12px 16px", minWidth: "70px",
            }}>
              <span style={{ fontSize: "22px", fontWeight: 800, color: p.onPrimCont, fontFamily: font, lineHeight: 1 }}>Nv {lvl}</span>
              <span style={{ fontSize: "10px", color: p.onPrimCont, marginTop: "4px", opacity: 0.7, fontFamily: mono }}>{xp.toLocaleString()} XP</span>
            </div>
          ))}
        </div>
      </StoryCard>
      <StoryCard title="Eventos de XP" hint="xp_log.event_type" p={p}>
        <div style={{ display: "flex", flexDirection: "column", gap: "8px" }}>
          {events.map(({ icon, label, xp, color, text }) => (
            <div key={label} style={{ display: "flex", alignItems: "center", justifyContent: "space-between", backgroundColor: p.surfaceVar, borderRadius: "12px", padding: "10px 14px" }}>
              <span style={{ fontSize: "13px", color: p.text, fontFamily: font }}>{icon} {label}</span>
              <span style={{ fontSize: "12px", fontWeight: 700, color: p.primary, fontFamily: font }}>{xp}</span>
            </div>
          ))}
        </div>
      </StoryCard>
    </>
  );
}

// ─── STORY: INPUT ─────────────────────────────────────────────────────────────
function StoryInput({ p }) {
  const [val, setVal] = useState("");
  const inputStyle = {
    width: "100%", fontFamily: font, fontSize: "14px", color: p.text,
    backgroundColor: p.surfaceVar, border: `1.5px solid ${p.outlineVar}`,
    borderRadius: "12px", padding: "12px 14px", outline: "none", boxSizing: "border-box",
  };
  return (
    <>
      <StoryCard title="Campo de nota" hint="user_note — texto/voz" p={p}>
        <input
          style={inputStyle} value={val}
          onChange={e => setVal(e.target.value)}
          placeholder="Ex.: whey com leite desnatado, extra cream..."
        />
      </StoryCard>
      <StoryCard title="Campo de kcal (stepper)" hint="kcal_point editável" p={p}>
        <KcalStepper p={p} />
      </StoryCard>
      <StoryCard title="Campo de pesagem" hint="weight_history" p={p}>
        <div style={{ display: "flex", gap: "10px", alignItems: "center" }}>
          <input style={{ ...inputStyle, width: "120px", textAlign: "center", fontSize: "20px", fontWeight: 700 }} defaultValue="80.5" />
          <span style={{ fontSize: "14px", color: p.textSub, fontFamily: font }}>kg</span>
          <span style={{ fontSize: "11px", color: p.textDis, fontFamily: mono }}>±0.1 kg</span>
        </div>
      </StoryCard>
    </>
  );
}
function KcalStepper({ p }) {
  const [val, setVal] = useState(470);
  return (
    <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
      <button onClick={() => setVal(v => Math.max(0, v - 10))} style={{ width: 40, height: 40, borderRadius: "12px", border: `1.5px solid ${p.outline}`, background: p.surface, color: p.text, fontSize: "20px", cursor: "pointer", fontFamily: font }}>−</button>
      <div style={{ textAlign: "center" }}>
        <span style={{ fontSize: "28px", fontWeight: 800, color: p.text, letterSpacing: "-1px", fontFamily: font }}>{val}</span>
        <span style={{ fontSize: "12px", color: p.textSub, marginLeft: "6px", fontFamily: font }}>kcal</span>
      </div>
      <button onClick={() => setVal(v => v + 10)} style={{ width: 40, height: 40, borderRadius: "12px", border: `1.5px solid ${p.outline}`, background: p.surface, color: p.text, fontSize: "20px", cursor: "pointer", fontFamily: font }}>+</button>
    </div>
  );
}

// ─── STORY: MEAL CARD ─────────────────────────────────────────────────────────
function StoryMealCard({ p, isDark }) {
  const statuses = [
    {
      name: "done — com foto",
      hint: "status = 'done', source = 'ai_photo'",
      time: "12:40", icon: "🍛", title: "Almoço", kcal: "~620 kcal",
      conf: "high", badge: null,
      detail: "Arroz · Feijão · Frango grelhado · Salada",
    },
    {
      name: "provisional — Quick Add",
      hint: "status = 'provisional', source = 'quick_add'",
      time: "08:12", icon: "🍳", title: "Café da manhã", kcal: "~380 kcal",
      conf: null, badge: { label: "Estimativa manual", color: p.secondaryCont, text: p.onSecCont },
      detail: "Inserido manualmente",
    },
    {
      name: "queued — aguardando IA",
      hint: "status = 'queued', source = 'ai_photo'",
      time: "16:05", icon: "🥤", title: "Whey", kcal: "---",
      conf: null, badge: { label: "⏳ Processando", color: p.surfaceVar, text: p.textSub },
      detail: "Aguardando conexão...",
    },
    {
      name: "barcode — produto escaneado",
      hint: "status = 'done', source = 'barcode'",
      time: "10:30", icon: "📦", title: "Whey Protein 100%", kcal: "~130 kcal",
      conf: null, badge: { label: "Barcode", color: p.primaryCont, text: p.onPrimCont },
      detail: "Dose de 35g · Gold Standard",
    },
    {
      name: "error — falha no processamento",
      hint: "status = 'error', retry_count = 3",
      time: "19:22", icon: "⚠️", title: "Jantar", kcal: "---",
      conf: null, badge: { label: "Falha ao processar", color: p.errorCont, text: p.onErrCont },
      detail: "Toque para reprocessar",
    },
  ];
  return (
    <>
      {statuses.map(({ name, hint, time, icon, title, kcal, conf, badge, detail }) => (
        <StoryCard key={name} title={name} hint={hint} p={p}>
          <div style={{
            display: "flex", alignItems: "center", gap: "14px",
            padding: "4px 0",
          }}>
            <span style={{ fontSize: "28px", flexShrink: 0 }}>{icon}</span>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                <span style={{ fontSize: "14px", fontWeight: 700, color: p.text, fontFamily: font }}>{title}</span>
                <span style={{ fontSize: "14px", fontWeight: 700, color: p.text, fontFamily: font }}>{kcal}</span>
              </div>
              <div style={{ display: "flex", gap: "8px", alignItems: "center", marginTop: "4px", flexWrap: "wrap" }}>
                <span style={{ fontSize: "11px", color: p.textSub, fontFamily: mono }}>{time}</span>
                <span style={{ fontSize: "11px", color: p.textDis }}>·</span>
                <span style={{ fontSize: "11px", color: p.textSub, fontFamily: font }}>{detail}</span>
                {badge && (
                  <span style={{
                    fontSize: "10px", fontWeight: 600, fontFamily: font,
                    backgroundColor: badge.color, color: badge.text,
                    padding: "2px 8px", borderRadius: "20px",
                  }}>{badge.label}</span>
                )}
                {conf === "high" && (
                  <span style={{ fontSize: "10px", fontWeight: 600, fontFamily: font, color: p.success }}>● Alta confiança</span>
                )}
              </div>
            </div>
          </div>
        </StoryCard>
      ))}
    </>
  );
}

// ─── STORY: ALERT NUDGE ──────────────────────────────────────────────────────
function StoryAlert({ p }) {
  const alerts = [
    { icon: "⚠️", title: "3 dias com proteína abaixo da meta", body: "Sua média ficou em 72g — meta é 130g. Hoje ainda dá tempo.", bg: p.errorCont, text: p.onErrCont, border: p.error },
    { icon: "📈", title: "Tendência inconclusiva", body: "Poucas pesagens na janela de 21 dias. Registre seu peso hoje para refinar a projeção.", bg: p.primaryCont, text: p.onPrimCont, border: p.primary },
    { icon: "✅", title: "Meta de proteína batida 7 dias seguidos", body: "+50 XP por dia. Continue — consistência é o motor.", bg: p.successCont, text: p.success, border: p.success },
    { icon: "💧", title: "Hidratação abaixo do ideal", body: "Você atingiu a meta de água em apenas 2 dos últimos 7 dias.", bg: p.secondaryCont, text: p.onSecCont, border: p.secondary },
  ];
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "10px" }}>
      {alerts.map(({ icon, title, body, bg, text, border }) => (
        <div key={title} style={{
          backgroundColor: bg, borderRadius: "14px", padding: "14px 16px",
          borderLeft: `3px solid ${border}`,
        }}>
          <div style={{ display: "flex", gap: "10px", alignItems: "flex-start" }}>
            <span style={{ fontSize: "16px", flexShrink: 0 }}>{icon}</span>
            <div>
              <p style={{ margin: "0 0 4px", fontSize: "13px", fontWeight: 700, color: text, fontFamily: font }}>{title}</p>
              <p style={{ margin: 0, fontSize: "12px", color: text, opacity: 0.8, fontFamily: font, lineHeight: 1.5 }}>{body}</p>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}

// ─── STORY: WATER STRIP ──────────────────────────────────────────────────────
function StoryWater({ p }) {
  const [ml, setMl] = useState(1250);
  const goal = 2500;
  const pct = ml / goal;
  return (
    <StoryCard title="Faixa de água — Home" hint="water_log · interativo" p={p}>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: "10px" }}>
        <div>
          <span style={{ fontSize: "18px", fontWeight: 800, color: p.text, fontFamily: font, letterSpacing: "-0.5px" }}>
            {(ml / 1000).toFixed(2).replace(".", ",")} L
          </span>
          <span style={{ fontSize: "12px", color: p.textSub, marginLeft: "6px", fontFamily: font }}>de {goal / 1000}L</span>
        </div>
        <div style={{ display: "flex", gap: "8px" }}>
          {[250, 500].map(v => (
            <button key={v} onClick={() => setMl(m => Math.min(m + v, 4000))} style={{
              padding: "9px 13px", borderRadius: "11px", border: "none",
              backgroundColor: p.primaryCont, color: p.onPrimCont,
              fontSize: "12px", fontWeight: 700, cursor: "pointer", fontFamily: font,
            }}>+{v}</button>
          ))}
        </div>
      </div>
      <div style={{ height: "6px", borderRadius: "3px", backgroundColor: p.surfaceVar }}>
        <div style={{ height: "100%", width: `${Math.min(pct, 1) * 100}%`, borderRadius: "3px", background: `linear-gradient(90deg, #5AAAD0, #2E7BA8)`, transition: "width 0.4s ease" }} />
      </div>
      <p style={{ margin: "6px 0 0", fontSize: "11px", color: p.textSub, fontFamily: font }}>
        {ml >= goal ? "✅ Meta atingida hoje" : `Faltam ${((goal - ml) / 1000).toFixed(2).replace(".", ",")} L`}
      </p>
    </StoryCard>
  );
}

// ─── STORY: HOME HEADER ──────────────────────────────────────────────────────
function StoryHomeHeader({ p, c, isDark }) {
  return (
    <StoryCard title="Home — topo completo" p={p}>
      <div style={{ display: "flex", gap: "20px", alignItems: "center", flexWrap: "wrap" }}>
        <Ring pct={0.72} size={140} strokeW={11} p={p} isDark={isDark} label="1.480" sublabel="de 2.050 kcal" />
        <div style={{ flex: 1, minWidth: "160px" }}>
          {[
            { label: "Proteína",     val: "92g",  meta: "130g", pct: 0.71, color: c.protein },
            { label: "Carboidratos", val: "150g", meta: "210g", pct: 0.71, color: c.carbs },
            { label: "Gordura",      val: "48g",  meta: "68g",  pct: 0.71, color: c.fat },
          ].map(({ label, val, meta, pct, color }) => (
            <div key={label} style={{ marginBottom: "11px" }}>
              <div style={{ display: "flex", justifyContent: "space-between", marginBottom: "4px" }}>
                <span style={{ fontSize: "12px", color: p.textSub, fontFamily: font, fontWeight: 500 }}>{label}</span>
                <span style={{ fontSize: "12px", fontWeight: 700, color: p.text, fontFamily: font }}>
                  {val} <span style={{ fontWeight: 400, color: p.textSub }}>/ {meta}</span>
                </span>
              </div>
              <div style={{ height: "5px", borderRadius: "3px", backgroundColor: p.surfaceVar }}>
                <div style={{ height: "100%", width: `${pct * 100}%`, borderRadius: "3px", backgroundColor: color }} />
              </div>
            </div>
          ))}
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginTop: "14px", paddingTop: "12px", borderTop: `1px solid ${p.divider}` }}>
            <span style={{ fontSize: "13px", color: p.textSub, fontFamily: font }}>💧 1,25L <span style={{ color: p.textDis }}>/ 2L</span></span>
            <span style={{ fontSize: "13px", color: p.primary, fontWeight: 700, fontFamily: font }}>⭐ Nv 4 · 1.230 XP</span>
          </div>
        </div>
      </div>
      <div style={{ marginTop: "18px", display: "flex", gap: "8px", flexWrap: "wrap" }}>
        <div style={{ background: `linear-gradient(135deg, ${isDark ? "#FFD780" : "#E08A10"}, ${p.primary})`, color: isDark ? "#2A1800" : "#fff", padding: "13px 20px", borderRadius: "16px", fontSize: "13px", fontWeight: 700, fontFamily: font, boxShadow: `0 4px 18px ${p.primary}50`, cursor: "pointer" }}>📷 Registrar</div>
        {["⚡ Quick Add", "📦 Barcode"].map(t => (
          <div key={t} style={{ backgroundColor: p.primaryCont, color: p.onPrimCont, padding: "11px 14px", borderRadius: "13px", fontSize: "12px", fontWeight: 600, fontFamily: font, cursor: "pointer" }}>{t}</div>
        ))}
      </div>
    </StoryCard>
  );
}

// ─── STORY: CONFIRM SHEET ─────────────────────────────────────────────────────
function StoryConfirmSheet({ p, c, isDark }) {
  const [kcal, setKcal] = useState(470);
  const base = 470;
  const ratio = kcal / base;
  const macros = { p: Math.round(31 * ratio), c: Math.round(45 * ratio), f: Math.round(14 * ratio) };
  const confInterval = kcal > 400 ? { lo: Math.round(kcal * 0.82), hi: Math.round(kcal * 1.38) } : { lo: Math.round(kcal * 0.78), hi: Math.round(kcal * 1.44) };
  return (
    <StoryCard title="Folha de confirmação pós-captura" hint="status: queued → edição do kcal_point" p={p}>
      {/* Thumbnail placeholder */}
      <div style={{ width: "100%", height: "120px", borderRadius: "14px", backgroundColor: p.surfaceVar, display: "flex", alignItems: "center", justifyContent: "center", marginBottom: "16px" }}>
        <span style={{ fontSize: "13px", color: p.textDis, fontFamily: font }}>📷 Foto capturada</span>
      </div>
      {/* Confidence */}
      <div style={{ display: "flex", alignItems: "center", gap: "8px", marginBottom: "14px" }}>
        <span style={{ fontSize: "12px", color: p.success, fontWeight: 600, fontFamily: font }}>● Alta confiança</span>
        <span style={{ fontSize: "11px", color: p.textDis, fontFamily: font }}>— talher identificado como referência de escala</span>
      </div>
      {/* Interval display */}
      <div style={{ backgroundColor: p.surfaceVar, borderRadius: "12px", padding: "12px 14px", marginBottom: "14px", display: "flex", justifyContent: "space-between" }}>
        <div style={{ textAlign: "center" }}>
          <p style={{ margin: 0, fontSize: "12px", color: p.textSub, fontFamily: font }}>Mínimo</p>
          <p style={{ margin: "4px 0 0", fontSize: "16px", fontWeight: 700, color: p.text, fontFamily: font }}>{confInterval.lo}</p>
        </div>
        <div style={{ textAlign: "center" }}>
          <p style={{ margin: 0, fontSize: "12px", color: p.textSub, fontFamily: font }}>Estimativa</p>
          <p style={{ margin: "4px 0 0", fontSize: "22px", fontWeight: 800, color: p.primary, fontFamily: font, letterSpacing: "-0.5px" }}>{kcal}</p>
          <p style={{ margin: "2px 0 0", fontSize: "11px", color: p.textSub, fontFamily: font }}>kcal</p>
        </div>
        <div style={{ textAlign: "center" }}>
          <p style={{ margin: 0, fontSize: "12px", color: p.textSub, fontFamily: font }}>Máximo</p>
          <p style={{ margin: "4px 0 0", fontSize: "16px", fontWeight: 700, color: p.text, fontFamily: font }}>{confInterval.hi}</p>
        </div>
      </div>
      {/* Stepper */}
      <div style={{ display: "flex", alignItems: "center", gap: "10px", marginBottom: "14px" }}>
        <button onClick={() => setKcal(v => Math.max(0, v - 10))} style={{ width: 38, height: 38, borderRadius: "11px", border: `1.5px solid ${p.outline}`, background: p.surface, color: p.text, fontSize: "18px", cursor: "pointer", fontFamily: font }}>−</button>
        <div style={{ flex: 1, height: "6px", borderRadius: "3px", backgroundColor: p.surfaceVar, cursor: "pointer" }}>
          <div style={{ height: "100%", width: `${Math.min(kcal / 1000, 1) * 100}%`, borderRadius: "3px", backgroundColor: p.primary }} />
        </div>
        <button onClick={() => setKcal(v => v + 10)} style={{ width: 38, height: 38, borderRadius: "11px", border: `1.5px solid ${p.outline}`, background: p.surface, color: p.text, fontSize: "18px", cursor: "pointer", fontFamily: font }}>+</button>
      </div>
      {/* Macro preview */}
      <p style={{ margin: "0 0 8px", fontSize: "11px", color: p.textDis, fontFamily: font }}>Macros ajustados proporcionalmente <span style={{ color: p.primary }}>— editável na V2</span></p>
      <div style={{ display: "flex", gap: "8px", marginBottom: "16px" }}>
        {[{ l: "P", v: `${macros.p}g`, col: c.protein }, { l: "C", v: `${macros.c}g`, col: c.carbs }, { l: "G", v: `${macros.f}g`, col: c.fat }].map(({ l, v, col }) => (
          <div key={l} style={{ flex: 1, backgroundColor: p.surfaceVar, borderRadius: "10px", padding: "10px", textAlign: "center" }}>
            <p style={{ margin: 0, fontSize: "10px", color: p.textSub, fontFamily: font }}>{l}</p>
            <p style={{ margin: "3px 0 0", fontSize: "15px", fontWeight: 700, color: p.text, fontFamily: font }}>{v}</p>
          </div>
        ))}
      </div>
      {/* CTA */}
      <button style={{ width: "100%", padding: "14px", borderRadius: "14px", border: "none", background: `linear-gradient(135deg, ${isDark?"#FFD780":"#E08A10"}, ${p.primary})`, color: isDark ? "#2A1800" : "#fff", fontSize: "14px", fontWeight: 700, cursor: "pointer", fontFamily: font }}>Salvar refeição</button>
    </StoryCard>
  );
}

// ─── STORY: ANALYTICS ────────────────────────────────────────────────────────
function StoryAnalytics({ p, c, isDark }) {
  const rawW =  [82.5, 82.1, 81.8, 82.3, 81.5, 81.2, 80.9, 81.4, 80.8, 80.5, 80.2, 80.6, 80.0, 79.8];
  const smthW = [82.4, 82.2, 82.0, 81.9, 81.7, 81.5, 81.3, 81.2, 81.0, 80.8, 80.6, 80.5, 80.3, 80.1];
  const proj =  [null, null, null, null, null, null, null, null, null, null, null, 80.5, 80.2, 80.1, 79.8, 79.5, 79.2, 78.9];

  function toPath(data, W, H, nullFill = false) {
    const valid = data.filter(v => v != null);
    const min = Math.min(...valid) - 0.3, max = Math.max(...valid) + 0.3;
    const xs = data.map((_, i) => (i / (data.length - 1)) * W);
    const ys = data.map(v => v == null ? null : H - ((v - min) / (max - min)) * H * 0.85 - H * 0.075);
    const pts = xs.map((x, i) => ({ x, y: ys[i] })).filter(pt => pt.y != null);
    return pts.map((pt, i) => `${i === 0 ? "M" : "L"} ${pt.x.toFixed(1)} ${pt.y.toFixed(1)}`).join(" ");
  }

  const W = 300, H = 80;
  return (
    <>
      <StoryCard title="Gráfico de peso — EMA + projeção" p={p}>
        <svg width="100%" viewBox={`0 0 ${W} ${H + 20}`} style={{ overflow: "visible" }}>
          <defs>
            <linearGradient id={`proj-${isDark}`} x1="0%" y1="0%" x2="100%" y2="0%">
              <stop offset="0%" stopColor={p.primary} stopOpacity="0.8" />
              <stop offset="100%" stopColor={p.primary} stopOpacity="0.2" />
            </linearGradient>
          </defs>
          {/* Raw points */}
          {rawW.map((v, i) => {
            const valid = rawW.filter(x => x != null);
            const min = Math.min(...valid) - 0.3, max = Math.max(...valid) + 0.3;
            const x = (i / (rawW.length - 1)) * W;
            const y = H - ((v - min) / (max - min)) * H * 0.85 - H * 0.075;
            return <circle key={i} cx={x} cy={y} r="2.5" fill={p.textDis} />;
          })}
          {/* Smoothed line */}
          <path d={toPath(smthW, W, H)} fill="none" stroke={p.primary} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
          {/* Projection (dashed) */}
          <path d={toPath(proj, W * (proj.length / rawW.length), H)} fill="none"
            stroke={`url(#proj-${isDark})`} strokeWidth="2" strokeDasharray="5,4" strokeLinecap="round" />
        </svg>
        <div style={{ display: "flex", gap: "16px", marginTop: "8px" }}>
          {[{ label: "● Peso cru", color: p.textDis }, { label: "── Suavizado (EMA)", color: p.primary }, { label: "-- Projeção", color: p.primary, opacity: 0.5 }].map(({ label, color, opacity }) => (
            <span key={label} style={{ fontSize: "11px", color, opacity, fontFamily: font }}>{label}</span>
          ))}
        </div>
        <div style={{ marginTop: "12px", backgroundColor: p.primaryCont, borderRadius: "12px", padding: "10px 14px" }}>
          <p style={{ margin: 0, fontSize: "13px", fontWeight: 700, color: p.onPrimCont, fontFamily: font }}>Meta provável: 12 – 19 set</p>
          <p style={{ margin: "3px 0 0", fontSize: "11px", color: p.onPrimCont, opacity: 0.75, fontFamily: font }}>IC 95% · −0,18 kg/dia (β1) · n=14 pesagens</p>
        </div>
      </StoryCard>
      <StoryCard title="Estatística descritiva — 30 dias" p={p}>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(4, 1fr)", gap: "10px" }}>
          {[
            { label: "Média", value: "1.920", unit: "kcal" },
            { label: "Mediana", value: "1.850", unit: "kcal" },
            { label: "DP", value: "320", unit: "kcal" },
            { label: "CV", value: "16.7", unit: "%" },
          ].map(({ label, value, unit }) => (
            <div key={label} style={{ backgroundColor: p.surfaceVar, borderRadius: "12px", padding: "12px 10px", textAlign: "center" }}>
              <p style={{ margin: 0, fontSize: "10px", color: p.textSub, fontFamily: font, fontWeight: 500 }}>{label}</p>
              <p style={{ margin: "5px 0 0", fontSize: "18px", fontWeight: 800, color: p.text, letterSpacing: "-0.5px", fontFamily: font }}>{value}</p>
              <p style={{ margin: "2px 0 0", fontSize: "10px", color: p.textDis, fontFamily: mono }}>{unit}</p>
            </div>
          ))}
        </div>
      </StoryCard>
      <StoryCard title="Mais consumidos (Frequência)" p={p}>
        {[
          { tag: "arroz", n: 28, pct: 0.93 },
          { tag: "frango grelhado", n: 22, pct: 0.73 },
          { tag: "ovo", n: 19, pct: 0.63 },
          { tag: "azeite", n: 16, pct: 0.53 },
          { tag: "whey", n: 12, pct: 0.40 },
        ].map(({ tag, n, pct }) => (
          <div key={tag} style={{ display: "flex", alignItems: "center", gap: "12px", marginBottom: "10px" }}>
            <span style={{ fontSize: "13px", color: p.text, fontFamily: font, minWidth: "130px" }}>{tag}</span>
            <div style={{ flex: 1, height: "5px", borderRadius: "3px", backgroundColor: p.surfaceVar }}>
              <div style={{ height: "100%", width: `${pct * 100}%`, borderRadius: "3px", backgroundColor: c.kcal }} />
            </div>
            <span style={{ fontSize: "11px", color: p.textSub, fontFamily: mono, minWidth: "24px", textAlign: "right" }}>{n}×</span>
          </div>
        ))}
      </StoryCard>
    </>
  );
}

// ─── STORIES REGISTRY ────────────────────────────────────────────────────────
const STORIES = [
  {
    category: "Foundations", icon: "◇",
    items: [
      { id: "colors",     label: "Colors",     render: (p, c, isDark) => <StoryColors p={p} c={c} isDark={isDark} /> },
      { id: "typography", label: "Typography", render: (p, c, isDark) => <StoryTypography p={p} /> },
    ],
  },
  {
    category: "Atoms", icon: "○",
    items: [
      { id: "button",       label: "Button",        render: (p, c, isDark) => <StoryButtons p={p} isDark={isDark} /> },
      { id: "chip",         label: "Chip",          render: (p, c, isDark) => <StoryChips p={p} /> },
      { id: "progress-ring",label: "Progress Ring", render: (p, c, isDark) => <StoryRing p={p} isDark={isDark} /> },
      { id: "progress-bar", label: "Progress Bar",  render: (p, c, isDark) => <StoryProgressBar p={p} c={c} /> },
      { id: "xp-badge",     label: "XP Badge",      render: (p, c, isDark) => <StoryBadge p={p} c={c} /> },
      { id: "input",        label: "Input",         render: (p, c, isDark) => <StoryInput p={p} /> },
    ],
  },
  {
    category: "Molecules", icon: "⬡",
    items: [
      { id: "meal-card",  label: "Meal Card",   render: (p, c, isDark) => <StoryMealCard p={p} isDark={isDark} /> },
      { id: "alert",      label: "Alert Nudge", render: (p, c, isDark) => <StoryAlert p={p} /> },
      { id: "water",      label: "Water Strip", render: (p, c, isDark) => <StoryWater p={p} /> },
    ],
  },
  {
    category: "Organisms", icon: "▣",
    items: [
      { id: "home-header",    label: "Home Header",     render: (p, c, isDark) => <StoryHomeHeader p={p} c={c} isDark={isDark} /> },
      { id: "confirm-sheet",  label: "Confirm Sheet",   render: (p, c, isDark) => <StoryConfirmSheet p={p} c={c} isDark={isDark} /> },
      { id: "analytics",      label: "Analytics Card",  render: (p, c, isDark) => <StoryAnalytics p={p} c={c} isDark={isDark} /> },
    ],
  },
];

// ─── APP ─────────────────────────────────────────────────────────────────────
export default function GemaStorybook() {
  const [mode, setMode]     = useState("light");
  const [activeId, setActiveId] = useState("home-header");
  const [openCats, setOpenCats] = useState({ Foundations: true, Atoms: true, Molecules: true, Organisms: true });
  const [mobileNav, setMobileNav] = useState(false);
  const isDark = mode === "dark";
  const p = T[mode], c = C[mode];

  useEffect(() => {
    const link = document.createElement("link");
    link.rel = "stylesheet";
    link.href = "https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=DM+Mono:wght@400;500&display=swap";
    document.head.appendChild(link);
  }, []);

  const activeStory = STORIES.flatMap(s => s.items).find(i => i.id === activeId);
  const activeCategory = STORIES.find(s => s.items.some(i => i.id === activeId));

  const toggleCat = (cat) => setOpenCats(prev => ({ ...prev, [cat]: !prev[cat] }));

  const SidebarContent = () => (
    <div style={{ padding: "8px 0" }}>
      {STORIES.map(({ category, icon, items }) => (
        <div key={category} style={{ marginBottom: "4px" }}>
          <button
            onClick={() => toggleCat(category)}
            style={{
              width: "100%", display: "flex", alignItems: "center", justifyContent: "space-between",
              padding: "8px 16px", background: "none", border: "none", cursor: "pointer",
              color: SB.text, fontSize: "11px", fontWeight: 700, letterSpacing: "1.5px",
              textTransform: "uppercase", fontFamily: font,
            }}
          >
            <span>{icon} {category}</span>
            <span style={{ opacity: 0.4, fontSize: "10px" }}>{openCats[category] ? "▾" : "▸"}</span>
          </button>
          {openCats[category] && items.map(({ id, label }) => {
            const isActive = id === activeId;
            return (
              <button
                key={id}
                onClick={() => { setActiveId(id); setMobileNav(false); }}
                style={{
                  width: "100%", textAlign: "left", display: "block",
                  padding: "8px 16px 8px 30px", background: isActive ? SB.active : "none",
                  border: "none", borderLeft: isActive ? `2px solid ${SB.accent}` : "2px solid transparent",
                  cursor: "pointer", color: isActive ? SB.accent : SB.text,
                  fontSize: "13px", fontWeight: isActive ? 600 : 400,
                  fontFamily: font, transition: "all 0.15s",
                }}
              >{label}</button>
            );
          })}
        </div>
      ))}
    </div>
  );

  return (
    <div style={{ display: "flex", flexDirection: "column", height: "100vh", backgroundColor: SB.bg, fontFamily: font }}>

      {/* ── Top bar ── */}
      <div style={{
        display: "flex", alignItems: "center", justifyContent: "space-between",
        padding: "0 20px", height: "52px", borderBottom: `1px solid ${SB.border}`,
        backgroundColor: SB.sidebar, flexShrink: 0,
      }}>
        <div style={{ display: "flex", alignItems: "center", gap: "14px" }}>
          <button
            onClick={() => setMobileNav(v => !v)}
            style={{ background: "none", border: "none", color: SB.textSub, cursor: "pointer", fontSize: "18px", padding: "4px", display: "flex" }}
          >☰</button>
          <span style={{ fontSize: "15px", fontWeight: 800, color: SB.accent, letterSpacing: "-0.5px" }}>gema</span>
          <span style={{ color: SB.textSub, fontSize: "13px" }}>/</span>
          <span style={{ color: SB.textSub, fontSize: "12px" }}>{activeCategory?.category}</span>
          <span style={{ color: SB.textSub, fontSize: "13px" }}>/</span>
          <span style={{ color: SB.text, fontSize: "12px", fontWeight: 600 }}>{activeStory?.label}</span>
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
          <span style={{ fontSize: "11px", color: SB.textSub }}>preview</span>
          <button
            onClick={() => setMode(isDark ? "light" : "dark")}
            style={{
              padding: "6px 14px", borderRadius: "20px", border: `1px solid ${SB.border}`,
              background: SB.active, color: SB.text, cursor: "pointer",
              fontSize: "12px", fontWeight: 600, fontFamily: font,
            }}
          >{isDark ? "☀️ Light" : "🌙 Dark"}</button>
        </div>
      </div>

      {/* ── Body ── */}
      <div style={{ display: "flex", flex: 1, overflow: "hidden" }}>

        {/* Sidebar */}
        <div style={{
          width: mobileNav ? "220px" : "0",
          minWidth: mobileNav ? "220px" : "0",
          backgroundColor: SB.sidebar,
          borderRight: `1px solid ${SB.border}`,
          overflowY: "auto", overflowX: "hidden",
          transition: "min-width 0.2s ease, width 0.2s ease",
          flexShrink: 0,
        }}>
          <SidebarContent />
        </div>

        {/* Fixed sidebar for wider screens */}
        <div style={{
          width: "220px", minWidth: "220px",
          backgroundColor: SB.sidebar,
          borderRight: `1px solid ${SB.border}`,
          overflowY: "auto",
          flexShrink: 0,
        }}>
          <SidebarContent />
        </div>

        {/* Main content */}
        <div style={{
          flex: 1, overflowY: "auto", backgroundColor: p.bg,
          padding: "28px 24px",
          transition: "background-color 0.3s ease",
        }}>
          <div style={{ maxWidth: "680px" }}>
            {/* Story header */}
            <div style={{ marginBottom: "24px" }}>
              <h1 style={{ margin: "0 0 4px", fontSize: "22px", fontWeight: 800, color: p.text, letterSpacing: "-0.5px", fontFamily: font }}>
                {activeStory?.label}
              </h1>
              <div style={{ display: "flex", gap: "8px", alignItems: "center" }}>
                <span style={{ fontSize: "11px", color: p.textSub, fontFamily: font }}>{activeCategory?.category}</span>
                <span style={{ width: "3px", height: "3px", borderRadius: "50%", backgroundColor: p.textDis, display: "inline-block" }} />
                <span style={{ fontSize: "11px", fontFamily: mono, color: p.textDis }}>gema · {mode}</span>
              </div>
            </div>
            <div style={{ height: "1px", backgroundColor: p.divider, marginBottom: "24px" }} />

            {/* Story render */}
            {activeStory?.render(p, c, isDark)}
          </div>
        </div>
      </div>
    </div>
  );
}
