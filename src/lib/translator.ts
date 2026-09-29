export type TranslationLanguage="en"|"pt"|"es";
export async function translateText(text:string,target:TranslationLanguage,source="auto"):Promise<string>{
 const q=text.trim(); if(!q)return "";
 const endpoint=(import.meta.env.VITE_TRANSLATION_API_URL as string|undefined)?.trim();
 const url=endpoint?endpoint+"?q="+encodeURIComponent(q)+"&source="+source+"&target="+target:
   "https://api.mymemory.translated.net/get?q="+encodeURIComponent(q)+"&langpair="+encodeURIComponent(source)+"%7C"+target;
 const res=await fetch(url,{headers:{"Accept":"application/json"}});
 if(!res.ok)throw new Error("Serviço de tradução indisponível");
 const data=await res.json();
 const translated=endpoint?data?.translatedText:data?.responseData?.translatedText;
 if(typeof translated!=="string"||!translated.trim())throw new Error("Não foi possível traduzir esta mensagem");
 return translated;
}