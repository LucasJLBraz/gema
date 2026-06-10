import { useState, useEffect } from "react";

// ─── DESIGN TOKENS ─────────────────────────────────────────────────────────
const tokens = {
  light: {
    // Surfaces
    bg:           "#F6F4F0",   // pedra fria — não creme
    surface:      "#FFFFFF",
    surfaceVar:   "#EBE3D8",
    surfaceEmph:  "#F0EDE8",

    // Brand
    primary:      "#B3700C",   // âmbar profundo — AA contrast ✓
    primaryCont:  "#FDDEA3",   // mel claro
    onPrimCont:   "#3A1F00",

    // Secondary
    secondary:    "#665940",
    secondaryCont:"#F2E5CC",
    onSecCont:    "#221A0A",

    // Text
    text:         "#1A1814",
    textSub:      "#4A3F32",
    textDisabled: "#9A8E80",

    // Structure
    outline:      "#BEB0A0",
    outlineVar:   "#E6DDD2",
    divider:      "#EBE3D8",

    // Semantic
    error:        "#B3261E",
    success:      "#386A20",
  },
  dark: {
    // Surfaces
    bg:           "#131110",   // quase preto, levemente quente
    surface:      "#1C1916",
    surfaceVar:   "#282320",
    surfaceEmph:  "#222018",

    // Brand
    primary:      "#F4BA52",   // âmbar vívido no escuro
    primaryCont:  "#472F00",
    onPrimCont:   "#FDDEA3",

    // Secondary
    secondary:    "#CDB998",
    secondaryCont:"#3A2E1C",
    onSecCont:    "#F2E5CC",

    // Text
    text:         "#EDE4D8",
    textSub:      "#A8957E",
    textDisabled: "#5A5048",

    // Structure
    outline:      "#38302A",
    outlineVar:   "#2A2420",
    divider:      "#282320",

    // Semantic
    error:        "#F2B8B5",
    success:      "#86C278",
  },
};

// Chart/data colors — semanticamente coerentes, distintos do primário
const chart = {
  light: {
    kcal:    "#B3700C",   // âmbar — primary
    protein: "#2E8B7A",   // teal-sage: construção, músculo
    carbs:   "#5C7EB0",   // azul-ardósia: energia, grão
    fat:     "#B86840",   // sienna quente: distinto do âmbar, família quente
  },
  dark: {
    kcal:    "#F4BA52",
    protein: "#5EC9B8",
    carbs:   "#87AEDC",
    fat:     "#E4916A",
  },
};

// ─── COMPONENT ─────────────────────────────────────────────────────────────
export default function GemaPalette() {
  const [mode, setMode] = useState("light");
  const isDark = mode === "dark";
  const p = tokens[mode];
  const c = chart[mode];

  useEffect(() => {
    const link = document.createElement("link");
    link.rel = "stylesheet";
    link.href =
      "https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=DM+Mono:wght@400;500&display=swap";
    document.head.appendChild(link);
  }, []);

  // Progress ring — assinatura visual
  const R = 58, stroke = 9;
  const circ = 2 * Math.PI * R;
  const progress = 0.72;
  const dashOffset = circ * (1 - progress);

  const card = (children, extra = {}) => ({
    backgroundColor: p.surface,
    borderRadius: "18px",
    padding: "20px",
    border: isDark ? `1px solid ${p.outlineVar}` : "none",
    boxShadow: isDark ? "none" : "0 1px 2px rgba(0,0,0,0.06), 0 4px 14px rgba(0,0,0,0.05)",
    ...extra,
  });

  const label = (text) => (
    <p style={{
      margin: "0 0 12px 0",
      fontSize: "10px",
      letterSpacing: "1.8px",
      textTransform: "uppercase",
      color: p.textSub,
      fontFamily: "'Plus Jakarta Sans', sans-serif",
      fontWeight: 600,
    }}>{text}</p>
  );

  return (
    <div style={{
      fontFamily: "'Plus Jakarta Sans', system-ui, sans-serif",
      backgroundColor: p.bg,
      minHeight: "100vh",
      padding: "28px 20px",
      color: p.text,
      transition: "background-color 0.3s ease, color 0.3s ease",
    }}>

      {/* ── Header ── */}
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: "36px" }}>
        <div>
          <div style={{ display: "flex", alignItems: "baseline", gap: "2px" }}>
            <span style={{
              fontSize: "34px",
              fontWeight: "800",
              letterSpacing: "-1.5px",
              color: p.primary,
              lineHeight: 1,
            }}>gema</span>
          </div>
          <span style={{
            fontSize: "10px",
            letterSpacing: "2.5px",
            textTransform: "uppercase",
            color: p.textSub,
            fontWeight: 500,
          }}>identidade visual · {isDark ? "dark" : "light"}</span>
        </div>

        {/* Toggle */}
        <button
          onClick={() => setMode(isDark ? "light" : "dark")}
          style={{
            display: "flex",
            alignItems: "center",
            gap: "6px",
            padding: "9px 16px",
            borderRadius: "24px",
            border: `1.5px solid ${p.outline}`,
            background: p.surface,
            color: p.text,
            cursor: "pointer",
            fontSize: "12px",
            fontWeight: 600,
            fontFamily: "inherit",
            transition: "all 0.2s ease",
          }}
        >
          {isDark ? "☀️ Light" : "🌙 Dark"}
        </button>
      </div>

      {/* ── Paleta de superfícies e marca ── */}
      <div style={{ marginBottom: "28px" }}>
        {label("Paleta de cores")}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(4, 1fr)", gap: "8px", marginBottom: "8px" }}>
          {[
            { name: "Primary",    hex: p.primary,      textColor: isDark ? "#1A1814" : "#fff" },
            { name: "P. Cont.",   hex: p.primaryCont,  textColor: p.onPrimCont },
            { name: "Secondary",  hex: p.secondary,    textColor: isDark ? "#1A1814" : "#fff" },
            { name: "S. Cont.",   hex: p.secondaryCont,textColor: p.onSecCont },
            { name: "Bg",         hex: p.bg,           textColor: p.textSub },
            { name: "Surface",    hex: p.surface,      textColor: p.textSub },
            { name: "Surf. Var.", hex: p.surfaceVar,   textColor: p.textSub },
            { name: "Divider",    hex: p.divider,      textColor: p.textSub },
          ].map(({ name, hex, textColor }) => (
            <div key={name}>
              <div style={{
                height: "56px",
                borderRadius: "12px",
                backgroundColor: hex,
                border: `1px solid ${isDark ? "rgba(255,255,255,0.05)" : "rgba(0,0,0,0.06)"}`,
                marginBottom: "6px",
                display: "flex",
                alignItems: "flex-end",
                padding: "6px 7px",
              }}>
                <span style={{
                  fontSize: "8px",
                  fontFamily: "'DM Mono', monospace",
                  color: textColor,
                  opacity: 0.85,
                }}>{hex}</span>
              </div>
              <p style={{
                margin: 0,
                fontSize: "9.5px",
                color: p.textSub,
                fontWeight: 500,
                letterSpacing: "0.2px",
              }}>{name}</p>
            </div>
          ))}
        </div>
      </div>

      {/* ── Text & Outline ── */}
      <div style={{ marginBottom: "28px" }}>
        {label("Texto & Estrutura")}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(4, 1fr)", gap: "8px" }}>
          {[
            { name: "Text",     hex: p.text },
            { name: "Text Sub", hex: p.textSub },
            { name: "Disabled", hex: p.textDisabled },
            { name: "Outline",  hex: p.outline },
          ].map(({ name, hex }) => (
            <div key={name}>
              <div style={{
                height: "40px",
                borderRadius: "10px",
                backgroundColor: hex,
                border: `1px solid ${isDark ? "rgba(255,255,255,0.05)" : "rgba(0,0,0,0.07)"}`,
                marginBottom: "6px",
              }} />
              <p style={{ margin: "0 0 1px 0", fontSize: "9.5px", color: p.textSub, fontWeight: 500 }}>{name}</p>
              <p style={{ margin: 0, fontSize: "9px", color: p.textDisabled, fontFamily: "'DM Mono', monospace" }}>{hex}</p>
            </div>
          ))}
        </div>
      </div>

      {/* ── Chart colors ── */}
      <div style={{ marginBottom: "28px" }}>
        {label("Dados & Gráficos")}
        <div style={{ ...card(), display: "flex", flexDirection: "column", gap: "14px" }}>
          {[
            { name: "Calorias (kcal)",   hex: c.kcal,    note: "primary" },
            { name: "Proteína",          hex: c.protein, note: "teal-sage" },
            { name: "Carboidratos",      hex: c.carbs,   note: "ardósia-azul" },
            { name: "Gordura",           hex: c.fat,     note: "sienna" },
          ].map(({ name, hex, note }) => (
            <div key={name} style={{ display: "flex", alignItems: "center", gap: "14px" }}>
              <div style={{
                width: "36px",
                height: "36px",
                borderRadius: "10px",
                backgroundColor: hex,
                flexShrink: 0,
              }} />
              <div style={{ flex: 1 }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline" }}>
                  <span style={{ fontSize: "13px", fontWeight: 600, color: p.text }}>{name}</span>
                  <span style={{ fontSize: "10px", fontFamily: "'DM Mono', monospace", color: p.textSub }}>{hex}</span>
                </div>
                {/* Mini bar preview */}
                <div style={{
                  marginTop: "5px",
                  height: "5px",
                  borderRadius: "3px",
                  backgroundColor: p.surfaceVar,
                  overflow: "hidden",
                }}>
                  <div style={{
                    height: "100%",
                    width: "68%",
                    borderRadius: "3px",
                    backgroundColor: hex,
                  }} />
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* ── UI mockup ── */}
      <div style={{ marginBottom: "28px" }}>
        {label("Componentes — Home")}

        {/* Progress card — signature element */}
        <div style={{ ...card(), marginBottom: "10px" }}>
          <div style={{ display: "flex", alignItems: "center", gap: "20px" }}>

            {/* Ring — ASSINATURA: gradiente que evoca faceta de gema */}
            <div style={{ position: "relative", flexShrink: 0, width: "128px", height: "128px" }}>
              <svg width="128" height="128" viewBox="0 0 128 128">
                <defs>
                  <linearGradient id={`ringGrad-${mode}`} x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%"   stopColor={isDark ? "#FFD780" : "#F5A820"} />
                    <stop offset="100%" stopColor={isDark ? "#E09010" : "#8B5200"} />
                  </linearGradient>
                </defs>
                {/* Track */}
                <circle
                  cx="64" cy="64" r={R}
                  fill="none"
                  stroke={p.surfaceVar}
                  strokeWidth={stroke}
                />
                {/* Progress — com gradiente */}
                <circle
                  cx="64" cy="64" r={R}
                  fill="none"
                  stroke={`url(#ringGrad-${mode})`}
                  strokeWidth={stroke}
                  strokeDasharray={circ}
                  strokeDashoffset={dashOffset}
                  strokeLinecap="round"
                  transform="rotate(-90 64 64)"
                />
              </svg>
              <div style={{
                position: "absolute",
                inset: 0,
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
                justifyContent: "center",
              }}>
                <span style={{
                  fontSize: "22px",
                  fontWeight: "800",
                  color: p.text,
                  letterSpacing: "-1px",
                  lineHeight: 1,
                }}>1.480</span>
                <span style={{
                  fontSize: "9.5px",
                  color: p.textSub,
                  marginTop: "3px",
                  fontWeight: 500,
                }}>de 2.050 kcal</span>
                <span style={{
                  fontSize: "10px",
                  color: p.primary,
                  fontWeight: 700,
                  marginTop: "4px",
                }}>72%</span>
              </div>
            </div>

            {/* Macro bars */}
            <div style={{ flex: 1 }}>
              {[
                { label: "Proteína", val: "92g",  meta: "130g", color: c.protein, pct: 0.71 },
                { label: "Carbos",   val: "150g", meta: "210g", color: c.carbs,   pct: 0.71 },
                { label: "Gordura",  val: "48g",  meta: "68g",  color: c.fat,     pct: 0.71 },
              ].map(({ label: l, val, meta, color, pct }) => (
                <div key={l} style={{ marginBottom: "11px" }}>
                  <div style={{ display: "flex", justifyContent: "space-between", marginBottom: "4px" }}>
                    <span style={{ fontSize: "11px", color: p.textSub, fontWeight: 500 }}>{l}</span>
                    <span style={{ fontSize: "11px", fontWeight: 700, color: p.text }}>
                      {val} <span style={{ fontWeight: 400, color: p.textSub, fontSize: "10px" }}>/ {meta}</span>
                    </span>
                  </div>
                  <div style={{
                    height: "5px",
                    borderRadius: "3px",
                    backgroundColor: p.surfaceVar,
                    overflow: "hidden",
                  }}>
                    <div style={{
                      height: "100%",
                      width: `${pct * 100}%`,
                      borderRadius: "3px",
                      backgroundColor: color,
                      transition: "width 0.5s ease",
                    }} />
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Água */}
        <div style={{
          ...card(),
          marginBottom: "10px",
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          padding: "14px 18px",
        }}>
          <span style={{ fontSize: "13px", color: p.textSub, fontWeight: 500 }}>💧 Água hoje</span>
          <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
            <span style={{ fontSize: "15px", fontWeight: 700, color: p.text }}>1.250 ml</span>
            {["+250", "+500"].map(t => (
              <button key={t} style={{
                padding: "6px 10px",
                borderRadius: "10px",
                border: "none",
                backgroundColor: p.surfaceVar,
                color: p.textSub,
                fontSize: "11px",
                fontWeight: 700,
                cursor: "pointer",
                fontFamily: "inherit",
              }}>{t}</button>
            ))}
          </div>
        </div>

        {/* Action buttons */}
        <div style={{ display: "flex", gap: "8px", flexWrap: "wrap" }}>
          {/* FAB principal */}
          <div style={{
            background: `linear-gradient(135deg, ${isDark ? "#FFD780" : "#E08A10"}, ${p.primary})`,
            color: isDark ? "#2A1800" : "#FFFFFF",
            padding: "13px 22px",
            borderRadius: "16px",
            fontSize: "13px",
            fontWeight: "700",
            display: "flex",
            alignItems: "center",
            gap: "7px",
            boxShadow: `0 4px 18px ${p.primary}50`,
            cursor: "pointer",
          }}>📷 Registrar</div>

          {/* Chips tonal */}
          {[
            { icon: "⚡", text: "Quick Add" },
            { icon: "📦", text: "Barcode" },
          ].map(({ icon, text }) => (
            <div key={text} style={{
              backgroundColor: p.primaryCont,
              color: p.onPrimCont,
              padding: "11px 14px",
              borderRadius: "13px",
              fontSize: "12px",
              fontWeight: 600,
              display: "flex",
              alignItems: "center",
              gap: "5px",
              cursor: "pointer",
            }}>{icon} {text}</div>
          ))}
        </div>
      </div>

      {/* ── Tipografia ── */}
      <div style={{ marginBottom: "12px" }}>
        {label("Tipografia — Plus Jakarta Sans")}
        <div style={{ ...card() }}>
          <div style={{ marginBottom: "18px" }}>
            <p style={{
              margin: "0 0 2px 0",
              fontSize: "32px",
              fontWeight: "800",
              letterSpacing: "-1.2px",
              color: p.text,
              lineHeight: 1.1,
            }}>2.050 kcal</p>
            <p style={{ margin: 0, fontSize: "11px", color: p.textDisabled, fontFamily: "'DM Mono', monospace" }}>
              800 · 32px · tracking -1.2px
            </p>
          </div>

          <div style={{ height: "1px", backgroundColor: p.divider, margin: "14px 0" }} />

          <div style={{ marginBottom: "14px" }}>
            <p style={{
              margin: "0 0 2px 0",
              fontSize: "18px",
              fontWeight: "700",
              letterSpacing: "-0.4px",
              color: p.text,
            }}>Análise de progresso</p>
            <p style={{ margin: 0, fontSize: "11px", color: p.textDisabled, fontFamily: "'DM Mono', monospace" }}>
              700 · 18px
            </p>
          </div>

          <div style={{ height: "1px", backgroundColor: p.divider, margin: "14px 0" }} />

          <div style={{ marginBottom: "14px" }}>
            <p style={{
              margin: "0 0 2px 0",
              fontSize: "14px",
              fontWeight: "400",
              color: p.textSub,
              lineHeight: 1.55,
            }}>
              Tendência dos últimos 21 dias indica meta provável entre{" "}
              <span style={{ color: p.primary, fontWeight: 600 }}>12–19 set</span>.
              Déficit médio semanal de 420 kcal.
            </p>
            <p style={{ margin: 0, fontSize: "11px", color: p.textDisabled, fontFamily: "'DM Mono', monospace" }}>
              400 · 14px · body
            </p>
          </div>

          <div style={{ height: "1px", backgroundColor: p.divider, margin: "14px 0" }} />

          <div>
            <p style={{
              margin: "0 0 2px 0",
              fontSize: "11px",
              fontWeight: 600,
              letterSpacing: "1.6px",
              textTransform: "uppercase",
              color: p.textSub,
            }}>Mais consumidos esta semana</p>
            <p style={{ margin: 0, fontSize: "11px", color: p.textDisabled, fontFamily: "'DM Mono', monospace" }}>
              600 · 11px · uppercase · tracking 1.6px · labels
            </p>
          </div>
        </div>
      </div>

      {/* Rodapé */}
      <p style={{
        textAlign: "center",
        fontSize: "10px",
        color: p.textDisabled,
        marginTop: "24px",
        fontFamily: "'DM Mono', monospace",
        letterSpacing: "0.5px",
      }}>
        gema · {mode} mode · plus jakarta sans + dm mono
      </p>
    </div>
  );
}
