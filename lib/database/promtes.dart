final prompt = """
"Analyze this plant image thoroughly.\n\n"
                            "IMPORTANT OUTPUT RULES (MANDATORY):\n"
                            "- Return ONLY valid JSON\n"
                            "- Do NOT include markdown, explanations, or comments\n"
                            "- Do NOT include line breaks inside string values\n"
                            "- All string values MUST be single-line\n"
                            "- Escape quotes properly\n"
                            "- If unsure, keep text short and simple\n"
                            "- If a value cannot be determined, return null\n"
                            "- Arrays must always be arrays, not strings\n\n"
                            "Return a comprehensive analysis inferred ONLY from the image and general botanical knowledge.\n\n"
                            "CORE ANALYSIS:\n"
                            "- Plant species (scientific name if possible)\n"
                            "- Health status (healthy/moderate/unhealthy/dying)\n"
                            "- Confidence score (0-1)\n"
                            "- Detailed description (single line, max 300 characters)\n"
                            "- 3-5 personalized care tips (single-line items)\n\n"
                            "PLANT CHARACTERISTICS:\n"
                            "- Common name\n"
                            "- Scientific name\n"
                            "- Plant family\n"
                            "- Native region\n"
                            "- Category (houseplant, tree, herb, etc.)\n"
                            "- Growth habit (upright, bushy, creeping, etc.)\n"
                            "- Natural habitat\n"
                            "- Leaf shape\n"
                            "- Growth pattern\n"
                            "- Best use (indoor decor, medicinal, air purification, etc.)\n"
                            "- Benefits (array of short items)\n\n"
                            "ENVIRONMENT & CARE DATA:\n"
                            "- Water needs (0-10)\n"
                            "- Water notes\n"
                            "- Sunlight needs (0-10)\n"
                            "- Sunlight notes\n"
                            "- Growth rate (0-10)\n"
                            "- Toxicity level (0-10)\n"
                            "- Bloom time (if applicable)\n"
                            "- Preferred soil type\n"
                            "- Temperature range\n"
                            "- Temperature notes\n"
                            "- Humidity level\n"
                            "- Humidity notes\n"
                            "- Fertilizer frequency\n"
                            "- Fertilizer notes\n"
                            "- Common issues (array)\n\n"
                            "UI INSIGHTS FOR HEALTH DASHBOARD:\n"
                            "- Health summary (overall label + short message)\n"
                            "- Pattern insights (watering, sunlight, or growth-related patterns)\n"
                            "- Care effectiveness (status of watering, sunlight, soil)\n"
                            "- Suggestions to improve growth (actionable, concise)\n\n"
                            "PLANT GROWTH PROGRESS DATA:\n"
                            "Generate progress data inferred from the current condition and typical growth behavior of the plant.\n"
                            "Do NOT use fixed dates or hardcoded values.\n"
                            "All values must be logically consistent and dynamically generated.\n"
                            "- Growth duration must reflect realistic biological growth for the identified plant species\n"
                            "- Dynamically choose time units such as days, weeks, or months based on actual plant growth speed\n"
                            "- Fast-growing plants should favor days or weeks, slow-growing plants should favor weeks or months\n"
                            "- Growth stages must represent real horticultural development stages such as seedling, acclimation, vegetative growth, branching, flowering, or maturity\n"
                            "- Timeline date labels must be relative (for example Day X, Week Y, Month Z) and chosen dynamically\n"
                            "- Timeline events must align logically with the total days_tracked value\n"
                            "- Growth chart trends must be biologically plausible, showing gradual growth and slowing near maturity\n\n"
                            "Progress data must include:\n"
                            "- Overall growth status label\n"
                            "- Total estimated days tracked (integer)\n"
                            "- Growth timeline events (chronological, concise)\n"
                            "- Growth chart data showing trends over time\n\n"
                            "ROUTINE & REMINDER DATA (FOR DAILY CARE UI):\n"
                            "Generate routine data suitable for a plant care dashboard.\n"
                            "This data must be consistent with the analysis above and inferred logically.\n"
                            "Rules:\n"
                            "- Keep text short and UI-friendly\n"
                            "- Do NOT repeat long explanations\n"
                            "- Tasks must be actionable and realistic\n"
                            "- Dates must be relative, not fixed calendar dates\n"
                            "Generate:\n"
                            "- routine_status: must be one of [Healthy, Attention, Critical]\n"
                            "- maintenance_level: one of [Low Maintenance, Medium Maintenance, High Maintenance]\n"
                            "- today_task: a single most important task for today\n"
                            "- ai_tip: one concise helpful tip (max 120 characters)\n"
                            "Routine timeline:\n"
                            "- 2-4 routine timeline items\n"
                            "- Each item must include title, subtitle, and isCompleted boolean\n"
                            "Upcoming care:"
                            "- 2–3 upcoming care items"
                            "- Each item must include:"
                            "  - title"
                            "  - subtitle"
                            "  - timeframe"
                            "  - icon"
                            ""
                            "- The \"icon\" field MUST be a single emoji character"
                            "- Use only emojis such as: ☀️ 💧 🌱 🍃 🧪"
                            "- Do NOT return words like \"sun\", \"water\", or \"growth\" for icon"
                            "- Do NOT return null or empty values"
                            "- Return valid JSON only, no explanations"
                            "Return ONLY a valid JSON object in this EXACT structure:\n"
                            "{\n"
                            "  \"species\": \"string\",\n"
                            "  \"health_status\": \"string\",\n"
                            "  \"confidence\": number,\n"
                            "  \"description\": \"string\",\n"
                            "  \"care_tips\": [\"string\"],\n\n"
                            "  \"common_name\": \"string\",\n"
                            "  \"scientific_name\": \"string\",\n"
                            "  \"family\": \"string\",\n"
                            "  \"native_region\": \"string\",\n\n"
                            "  \"category\": \"string\",\n"
                            "  \"growth_habit\": \"string\",\n"
                            "  \"natural_habitat\": \"string\",\n"
                            "  \"leaf_shape\": \"string\",\n"
                            "  \"growth_pattern\": \"string\",\n"
                            "  \"best_for\": \"string\",\n"
                            "  \"benefits\": [\"string\"],\n\n"
                            "  \"water_needs\": number,\n"
                            "  \"water_notes\": \"string\",\n"
                            "  \"sunlight_needs\": number,\n"
                            "  \"sunlight_notes\": \"string\",\n"
                            "  \"growth_rate\": number,\n"
                            "  \"toxicity_level\": number,\n"
                            "  \"bloom_time\": \"string\",\n"
                            "  \"soil_type\": \"string\",\n\n"
                            "  \"temperature_range\": \"string\",\n"
                            "  \"temperature_notes\": \"string\",\n"
                            "  \"humidity_level\": \"string\",\n"
                            "  \"humidity_notes\": \"string\",\n"
                            "  \"fertilizer_frequency\": \"string\",\n"
                            "  \"fertilizer_notes\": \"string\",\n"
                            "  \"common_issues\": [\"string\"],\n\n"
                            "  \"ui_insights\": {\n"
                            "    \"health_summary\": {\n"
                            "      \"overall_health\": \"string\",\n"
                            "      \"message\": \"string\"\n"
                            "    },\n"
                            "    \"pattern_insights\": [\n"
                            "      {\n"
                            "        \"type\": \"string\",\n"
                            "        \"icon\": \"string\",\n"
                            "        \"message\": \"string\"\n"
                            "      }\n"
                            "    ],\n"
                            "    \"care_effectiveness\": {\n"
                            "      \"watering\": \"string\",\n"
                            "      \"sunlight\": \"string\",\n"
                            "      \"soil\": \"string\"\n"
                            "    },\n"
                            "    \"growth_suggestions\": [\"string\"]\n"
                            "  },\n\n"
                            "  \"growth_progress\": {\n"
                            "    \"overall_status\": \"string\",\n"
                            "    \"days_tracked\": number,\n"
                            "    \"timeline\": [\n"
                            "      {\n"
                            "        \"date\": \"string\",\n"
                            "        \"title\": \"string\",\n"
                            "        \"status\": \"string\"\n"
                            "      }\n"
                            "    ],\n"
                            "    \"chart\": {\n"
                            "      \"labels\": [\"string\"],\n"
                            "      \"height\": [number],\n"
                            "      \"leaves\": [number]\n"
                            "    }\n"
                            "  },\n\n"
                            "  \"routine\": {\n"
                            "    \"routine_status\": \"string\",\n"
                            "    \"maintenance_level\": \"string\",\n"
                            "    \"today_task\": \"string\",\n"
                            "    \"ai_tip\": \"string\",\n"
                            "    \"timeline\": [\n"
                            "      {\n"
                            "        \"title\": \"string\",\n"
                            "        \"subtitle\": \"string\",\n"
                            "        \"isCompleted\": boolean\n"
                            "      }\n"
                            "    ],\n"
                            "    \"upcoming_care\": [\n"
                            "      {\n"
                            "        \"title\": \"string\",\n"
                            "        \"subtitle\": \"string\",\n"
                            "        \"timeframe\": \"string\"\n"
                            "     \"icon\": \"emoji\"\n"
                            "      }\n"
                            "    ]\n"
                            "  }\n"
                            "}""";
final String getPlantDataPrompt = '''
"Analyze this plant image thoroughly."

"IMPORTANT OUTPUT RULES (MANDATORY):"
"- Return ONLY valid JSON"
"- Do NOT include markdown, explanations, or comments"
"- Do NOT include line breaks inside string values"
"- All string values MUST be single-line"
"- Escape quotes properly"
"- If unsure, keep text short and simple"
"- If a value cannot be determined, return null"
"- Arrays must always be arrays, not strings"

"Return a comprehensive analysis inferred ONLY from the image and general botanical knowledge."

"CORE ANALYSIS:"
"- Plant species (scientific name if possible)"
"- Health status (healthy/moderate/unhealthy/dying)"
"- Confidence score (0-1)"
"- Detailed description (single line, max 300 characters)"
"- 3-5 personalized care tips (single-line items)"

"PLANT CHARACTERISTICS:"
"- Common name"
"- Scientific name"
"- Plant family"
"- Native region"
"- Category (houseplant, tree, herb, etc.)"
"- Growth habit (upright, bushy, creeping, etc.)"
"- Natural habitat"
"- Leaf shape"
"- Growth pattern"
"- Best use (indoor decor, medicinal, air purification, etc.)"
"- Benefits (array of short items)"

"ENVIRONMENT & CARE DATA:"
"- Water needs (0-10)"
"- Water notes"
"- Sunlight needs (0-10)"
"- Sunlight notes"
"- Growth rate (0-10)"
"- Toxicity level (0-10)"
"- Bloom time (if applicable)"
"- Preferred soil type"
"- Temperature range"
"- Temperature notes"
"- Humidity level"
"- Humidity notes"
"- Fertilizer frequency"
"- Fertilizer notes"
"- Common issues (array)"

"UI INSIGHTS FOR HEALTH DASHBOARD:"
"- Health summary (overall label + short message)"
"- Pattern insights (watering, sunlight, or growth-related patterns)"
"- Care effectiveness (status of watering, sunlight, soil)"
"- Suggestions to improve growth (actionable, concise)"

"PLANT GROWTH PROGRESS DATA:"
"- Generate realistic, biologically plausible growth progress"
"- Use relative time labels (Day X, Week Y, Month Z)"
"- Growth stages must match real horticultural stages"

"ROUTINE & REMINDER DATA:"
"- routine_status: Healthy | Attention | Critical"
"- maintenance_level: Low | Medium | High Maintenance"
"- today_task: one most important task"
"- ai_tip: max 120 characters"
"- Icons must be a single emoji only (☀️ 💧 🌱 🍃 🧪)"

"Return ONLY a valid JSON object in this EXACT structure:"
{
  "species": "string",
  "health_status": "string",
  "confidence": number,
  "description": "string",
  "care_tips": ["string"],

  "common_name": "string",
  "scientific_name": "string",
  "family": "string",
  "native_region": "string",

  "category": "string",
  "growth_habit": "string",
  "natural_habitat": "string",
  "leaf_shape": "string",
  "growth_pattern": "string",
  "best_for": "string",
  "benefits": ["string"],

  "water_needs": number,
  "water_notes": "string",
  "sunlight_needs": number,
  "sunlight_notes": "string",
  "growth_rate": number,
  "toxicity_level": number,
  "bloom_time": "string",
  "soil_type": "string",

  "temperature_range": "string",
  "temperature_notes": "string",
  "humidity_level": "string",
  "humidity_notes": "string",
  "fertilizer_frequency": "string",
  "fertilizer_notes": "string",
  "common_issues": ["string"],

  "ui_insights": {
    "health_summary": {
      "overall_health": "string",
      "message": "string"
    },
    "pattern_insights": [
      {
        "type": "string",
        "icon": "emoji",
        "message": "string"
      }
    ],
    "care_effectiveness": {
      "watering": "string",
      "sunlight": "string",
      "soil": "string"
    },
    "growth_suggestions": ["string"]
  },

  "growth_progress": {
    "overall_status": "string",
    "days_tracked": number,
    "timeline": [
      {
        "date": "string",
        "title": "string",
        "status": "string"
      }
    ],
    "chart": {
      "labels": ["string"],
      "height": [number],
      "leaves": [number]
    }
  },

  "routine": {
    "routine_status": "string",
    "maintenance_level": "string",
    "today_task": "string",
    "ai_tip": "string",
    "timeline": [
      {
        "title": "string",
        "subtitle": "string",
        "isCompleted": boolean
      }
    ],
    "upcoming_care": [
      {
        "title": "string",
        "subtitle": "string",
        "timeframe": "string",
        "icon": "emoji"
      }
    ]
  }
}
''';
final String plantStatusPrompt = '''
"Analyze this plant image and return ONLY the data needed for the following data models."

"RULES:"
"- Return ONLY valid JSON"
"- Do NOT include markdown, code fences, or explanations"
"- Do NOT include any extra fields or change field names"
"- If unsure about any value, return null"
"- Keep all text values concise (max 200 characters)"
"- Plant status must be one of: ['Healthy', 'Needs Attention', 'Critical', 'Thriving', 'Struggling', 'Dormant']"
"- statusColor MUST be a HEX color string in format '#RRGGBB' ONLY"
"- additionalStatus MUST be ONLY 1 or 2 words (no sentences, no punctuation)"
"- additionalStatusColor MUST be a HEX color string in format '#RRGGBB' ONLY"
"- Do NOT return color names like 'green', 'red', 'yellow'"
"- Last updated must be current timestamp in ISO 8601 format"

"STATUS TO COLOR MAPPING (STRICT):"
"- Healthy -> #4CAF50"
"- Thriving -> #2E7D32"
"- Needs Attention -> #FFC107"
"- Struggling -> #FF9800"
"- Critical -> #F44336"
"- Dormant -> #9E9E9E"

"ADDITIONAL STATUS TO COLOR MAPPING (STRICT):"
"- Needs Water -> #42A5F5"
"- Mature -> #66BB6A"
"- Growing -> #81C784"
"- Low Light -> #FFB300"
"- Overwatered -> #EF5350"
"- Pest Risk -> #AB47BC"
"- Normal Growth -> #26A69A"

"REQUIRED DATA FOR DairyPlantModel:"
{
  "name": "string (plant common name)",
  "imageUrl": "string (describe the plant image)",
  "status": "string (plant health status)",
  "statusColor": "string (HEX color #RRGGBB)",
  "lastUpdated": "string (current timestamp)",
  "additionalStatus": "string",
  "additionalStatusColor": "string"
}

"REQUIRED DATA FOR PlantEntry (first diagnostic entry):"
{
  "description": "string (brief plant analysis)",
  "imageUrl": "string (same as plant image)",
  "status": "string (analysis status)",
  "timestamp": "string (current timestamp)",
  "updateTime": "string (current timestamp)"
}

"Return EXACTLY this JSON structure with no additional fields:"
{
  "plant": {
    "name": "string",
    "imageUrl": "string",
    "status": "string",
    "statusColor": "string",
    "lastUpdated": "string",
    "additionalStatus": "string",
    "additionalStatusColor": "string"
  },
  "entry": {
    "description": "string",
    "imageUrl": "string",
    "status": "string",
    "timestamp": "string",
    "updateTime": "string"
  }
}
''';
