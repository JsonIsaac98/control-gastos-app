import 'package:flutter/material.dart';

/// Paleta "Deep Royal" – Elegancia Total (estilo banca de lujo / tarjeta Black)
/// ──────────────────────────────────────────────────────────────────────────
/// Light  │ Fondo: #F4F7FE  Cards: #FFFFFF  Primary: #4318FF
///        │ Secondary: #B0BBD5   Texto: #2B3674
/// ──────────────────────────────────────────────────────────────────────────
/// Dark   │ Fondo: #050505  Cards: #121212  Primary: #707EAE
///        │ Secondary: #1B254B   Texto: #FFFFFF
/// ──────────────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // ── LIGHT MODE ────────────────────────────────────────────────────────────
  static const surfaceLight          = Color(0xFFF4F7FE); // Azul muy pálido
  static const cardLight             = Color(0xFFFFFFFF); // Cards blancas
  static const primaryLight          = Color(0xFF4318FF); // Azul eléctrico
  static const secondaryLight        = Color(0xFFB0BBD5); // Azul grisáceo
  static const textLight             = Color(0xFF2B3674); // Azul profundo

  // Contenedores light
  static const primaryContainerLight   = Color(0xFFE0DBFF); // azul muy claro
  static const secondaryContainerLight = Color(0xFFE8EDF7); // gris azulado suave
  static const surfaceVariantLight     = Color(0xFFD8DDED); // separadores

  // ── DARK MODE ─────────────────────────────────────────────────────────────
  static const surfaceDark           = Color(0xFF050505); // Negro total
  static const cardDark              = Color(0xFF121212); // Gris grafito
  static const primaryDark           = Color(0xFF707EAE); // Azul acero
  static const secondaryDark         = Color(0xFF1B254B); // Azul marino
  static const textDark              = Color(0xFFFFFFFF); // Blanco total

  // Contenedores dark
  static const primaryContainerDark   = Color(0xFF1B254B); // azul marino
  static const secondaryContainerDark = Color(0xFF0D1530); // azul muy oscuro
  static const surfaceVariantDark     = Color(0xFF1A1F35); // separadores oscuros

  // ── COLORES SEMÁNTICOS – TIPOS DE PAGO ───────────────────────────────────
  // Efectivo → verde (universal = dinero en efectivo)
  static const efectivo        = Color(0xFF059669);
  static const efectivoDark    = Color(0xFF34D399);
  static const efectivoBg      = Color(0xFFD1FAE5);
  static const efectivoBgDark  = Color(0xFF022C22);

  // Tarjeta de crédito → azul eléctrico (alineado con primario)
  static const tarjeta         = Color(0xFF4318FF);
  static const tarjetaDark     = Color(0xFF707EAE);
  static const tarjetaBg       = Color(0xFFE0DBFF);
  static const tarjetaBgDark   = Color(0xFF1B254B);

  // Transferencia → cyan / índigo claro
  static const transfer        = Color(0xFF0891B2);
  static const transferDark    = Color(0xFF22D3EE);
  static const transferBg      = Color(0xFFCFFAFE);
  static const transferBgDark  = Color(0xFF083344);
}
