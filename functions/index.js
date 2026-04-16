const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { OpenAI } = require("openai");

admin.initializeApp();

// OpenAI API key sadece Cloud Function ortamında tutuluyor
// Dağıtımdan önce: firebase functions:config:set openai.key="sk-..."
function getOpenAIClient() {
  const key = functions.config().openai?.key || process.env.OPENAI_API_KEY;
  if (!key) throw new Error("OpenAI API key yapılandırılmamış");
  return new OpenAI({ apiKey: key });
}

// Rate limit: kullanıcı başına saatte 20 istek
const rateLimitMap = new Map();

function checkRateLimit(uid) {
  const now = Date.now();
  const window = 60 * 60 * 1000; // 1 saat
  const limit = 20;

  if (!rateLimitMap.has(uid)) {
    rateLimitMap.set(uid, []);
  }
  const requests = rateLimitMap.get(uid).filter((t) => now - t < window);
  if (requests.length >= limit) return false;
  requests.push(now);
  rateLimitMap.set(uid, requests);
  return true;
}

// ─────────────────────────────────────────────────
// Kahve Falı
// ─────────────────────────────────────────────────
function buildCoffeePrompt(topic, userNote) {
  return `Sen deneyimli ve sezgisel bir Türk kahve falcısısın. Kullanıcının fincanına derin bir şekilde baktın ve şimdi ona çok ayrıntılı, gerçekçi ve inandırıcı bir kahve falı yorumu yapacaksın.

Konu: ${topic}
Kullanıcının anlattığı durum: ${userNote || "Genel bir bakış isteniyor"}

Yorumunu aşağıdaki yapıda yap (her bölüm en az 3-4 paragraf olsun):

🔮 GENEL ENERJİ VE ATMOSFER
Fincanın genel enerjisini ve atmosferini anlat. Kahve telvesindeki şekilleri ve sembolleri yorumla.

☕ ${topic} KONUSUNDA DETAYLI BAKIŞ
Kullanıcının belirttiği konuya özel, çok detaylı yorum yap. En az 5 paragraf. O konuya doğrudan hitap et.

🌙 GİZLİ İŞARETLER VE SEMBOLLER
Fincanda gördüğün özel sembolleri ve gizli mesajları anlat.

⏳ ZAMAN DİLİMLERİ
Yakın gelecek (1-3 ay), orta vade (3-6 ay) ve uzun vade için ayrı yorumlar yap.

💌 FALCI TEYZE'NİN ÖZEL MESAJI
Kişiye özel, samimi ve güçlü bir kapanış mesajı.

ÖNEMLİ: Tarot kartı, el çizgisi veya kahve dışı yöntemlerden hiç bahsetme. Sadece kahve falı yorumu yap. Türkçe yaz.`;
}

// ─────────────────────────────────────────────────
// Tarot Falı
// ─────────────────────────────────────────────────
function buildTarotPrompt(topic, userNote, cardNames) {
  const positions = ["Geçmiş", "Şimdiki Durum", "Yakın Gelecek", "Sonuç"];
  const cardsText = cardNames
    .map((c, i) => `${positions[i] || `Kart ${i + 1}`}: ${c}`)
    .join("\n");

  return `Sen derin sezgili ve deneyimli bir Tarot yorumcususun. Kullanıcı için 4 kartlık bir Tarot açılımı yaptın.

Çekilen Kartlar:
${cardsText}

Konu: ${topic}
Kullanıcının anlattığı durum: ${userNote || "Genel bir bakış isteniyor"}

Yorumunu aşağıdaki yapıda yap:

✨ AÇILIM GENEL ENERJİSİ
Bu 4 kartın bir araya getirdiği enerji ve mesaj. En az 3 paragraf.

🃏 KART KART DETAYLI YORUM

**GEÇMIŞ - ${cardNames[0] || "Kart 1"}**
Bu kartın ${topic} konusundaki geçmiş anlamı. En az 4 paragraf.

**ŞİMDİKİ DURUM - ${cardNames[1] || "Kart 2"}**
Şu anki enerji ve süreç. En az 4 paragraf.

**YAKIN GELECEK - ${cardNames[2] || "Kart 3"}**
Yakın dönemdeki gelişmeler. En az 4 paragraf.

**SONUÇ - ${cardNames[3] || "Kart 4"}**
Bu sürecin sonucu ve olası final. En az 4 paragraf.

🌟 ${topic} KONUSUNA ÖZEL MESAJ
Kullanıcının belirttiği konuya özel değerlendirme.

💫 TAROT'UN ÖZEL TAVSİYELERİ
Kişiye özel tavsiyeler ve kapanış.

ÖNEMLİ: Kahve fincanı, telve, kristal küre veya tarot dışı yöntemlerden hiç bahsetme. Sadece Tarot kartı yorumu yap. Türkçe yaz.`;
}

// ─────────────────────────────────────────────────
// El Falı
// ─────────────────────────────────────────────────
function buildPalmPrompt(topic, userNote) {
  return `Sen deneyimli bir el falcısısın (kiromonsi uzmanı). Kullanıcının avuç içini ve el hatlarını derin şekilde okudun.

Konu: ${topic}
Kullanıcının durumu: ${userNote || "Genel bir bakış isteniyor"}

El hattı yorumunu şu yapıda yap:

🖐 GENEL ENERJİ
Elin genel enerjisi ve aura'sı hakkında derin yorum.

💗 KALP ÇİZGİSİ
Kalp çizgisinden okunan sevgi, ilişki ve duygusal durumu anlat.

🌿 YAŞAM ÇİZGİSİ
Yaşam çizgisinden okunan sağlık, enerji ve yaşam gücünü anlat.

⭐ KADER ÇİZGİSİ
Kader çizgisinden okunan kariyer, başarı ve hayat yolunu anlat.

💡 BAŞ ÇİZGİSİ
Zihinsel yapı ve düşünce tarzını anlat.

📅 ZAMANLAMA
Yakın dönem (1-3 ay), orta dönem (3-6 ay), uzun dönem.

🔮 FALCI TEYZE'NİN MESAJI
Kişiye özel kapanış mesajı.

ÖNEMLİ: Kahve fincanı, telve, tarot kartı veya el dışı yöntemlerden hiç bahsetme. Sadece el hattı yorumu yap. ${topic} konusuna özellikle değin. Türkçe yaz. Minimum 600 kelime.`;
}

// ─────────────────────────────────────────────────
// Ana Cloud Function: generateFalReading
// ─────────────────────────────────────────────────
exports.generateFalReading = functions
  .region("europe-west1")
  .runWith({ timeoutSeconds: 120, memory: "512MB" })
  .https.onCall(async (data, context) => {
    // Auth kontrolü
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Giriş yapmanız gerekiyor."
      );
    }

    const uid = context.auth.uid;

    // Rate limit kontrolü
    if (!checkRateLimit(uid)) {
      throw new functions.https.HttpsError(
        "resource-exhausted",
        "Çok fazla istek gönderdiniz. Lütfen biraz bekleyin."
      );
    }

    const { falType, topic, userNote, cardNames } = data;

    // Giriş doğrulama
    if (!falType || !["coffee", "tarot", "palm"].includes(falType)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Geçersiz fal türü."
      );
    }
    if (!topic) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Konu belirtilmeli."
      );
    }

    // Prompt seç
    let prompt;
    if (falType === "coffee") {
      prompt = buildCoffeePrompt(topic, userNote);
    } else if (falType === "tarot") {
      if (!cardNames || cardNames.length < 4) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "Tarot için 4 kart gerekli."
        );
      }
      prompt = buildTarotPrompt(topic, userNote, cardNames);
    } else {
      prompt = buildPalmPrompt(topic, userNote);
    }

    try {
      const openai = getOpenAIClient();
      console.log(`[FAL] calling OpenAI — falType=${falType} uid=${uid}`);
      const response = await openai.chat.completions.create({
        model: "gpt-4o-mini",
        messages: [
          {
            role: "system",
            content:
              "Sen Falcım uygulamasının sezgisel falcı asistanısın. Her zaman uzun, detaylı, inandırıcı ve kişiye özel yorumlar yaparsın. Seçilen fal türü dışında başka yöntemlerden bahsetmezsin. Türkçe konuşursun.",
          },
          { role: "user", content: prompt },
        ],
        max_tokens: 3000,
        temperature: 0.85,
      });

      const reading = response.choices[0]?.message?.content;
      if (!reading) {
        console.error("[FAL] OpenAI returned empty content", JSON.stringify(response.choices));
        throw new functions.https.HttpsError("internal", "OpenAI boş yanıt döndürdü.");
      }
      console.log(`[FAL] OpenAI success — tokens=${response.usage?.total_tokens || 0} chars=${reading.length}`);

      // Firestore'a loglama (isteğe bağlı)
      await admin.firestore().collection("readings_log").add({
        uid,
        falType,
        topic,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        tokenCount: response.usage?.total_tokens || 0,
      });

      return { reading };
    } catch (error) {
      if (error instanceof functions.https.HttpsError) throw error;
      console.error("[FAL] error — code:", error?.status, "type:", error?.type, "message:", error?.message, "stack:", error?.stack);
      if (error?.status === 401 || error?.message?.includes("API key")) {
        throw new functions.https.HttpsError("internal", "OpenAI API anahtarı geçersiz veya eksik.");
      }
      if (error?.status === 429 || error?.message?.includes("rate limit") || error?.message?.includes("quota")) {
        throw new functions.https.HttpsError("resource-exhausted", "OpenAI kota aşıldı. Lütfen daha sonra tekrar deneyin.");
      }
      if (error?.status === 503 || error?.message?.includes("timeout") || error?.code === "ETIMEDOUT") {
        throw new functions.https.HttpsError("deadline-exceeded", "OpenAI yanıt vermedi. Lütfen tekrar deneyin.");
      }
      throw new functions.https.HttpsError("internal", `Yorum oluşturulamadı: ${error?.message || "Bilinmeyen hata"}`);
    }
  });
