#!/usr/bin/env bun
type Answer={type:"choice";confidence?:number;choice:string;probabilities:Record<string,number>};
const API=process.env.FAFA_LAYA_URL??"http://127.0.0.1:8080/v1/systemone";
const LOG=process.env.FAFA_LAYA_LOG??`${process.env.HOME??"."}/.local/state/fafa-laya/decisions.jsonl`;
const get=(n:string)=>{const i=Bun.argv.indexOf(n);return i<0?undefined:Bun.argv[i+1]};
const state=get("--state"), question=get("--question"), key=get("--key")??"decision";
const choices=get("--choices")?.split(",").map(x=>x.trim()).filter(Boolean);
if(!state||!question||!choices||choices.length<2){
 console.error('Usage: bun .agents/scripts/laya_decide.ts --state "..." --question "..." --choices implement,planner [--key next_actor]');
 process.exit(2);
}
const result:{choice:string|null;confidence:number|null;probabilities:Record<string,number>;fallback:boolean;reason?:string}=
 {choice:null,confidence:null,probabilities:{},fallback:true};
try{
 const r=await fetch(API,{method:"POST",headers:{"content-type":"application/json"},body:JSON.stringify({
  state,questions:{[key]:{type:"choice",instructions:question,criteria:Object.fromEntries(choices.map(c=>[c,c]))}}
 }),signal:AbortSignal.timeout(2500)});
 if(!r.ok) result.reason=`http_${r.status}`;
 else{
  const body=await r.json() as {answers?:Record<string,Answer>};
  const a=body.answers?.[key];
  if(!a||a.type!=="choice"||!choices.includes(a.choice)) result.reason="invalid_answer";
  else{
   const ranked=Object.values(a.probabilities??{}).sort((a,b)=>b-a);
   const top1=ranked[0]??0, top2=ranked[1]??0, margin=top1-top2;
   result.choice=a.choice; result.confidence=a.confidence??null; result.probabilities=a.probabilities??{};
   const safe=top1>=0.70&&margin>=0.25;
   result.fallback=!safe;
   if(!safe) result.reason="ambiguous_distribution";
  }
 }
}catch(e){result.reason=e instanceof Error?`request_failed:${e.name}`:"request_failed"}
try{
 const dir=LOG.slice(0,LOG.lastIndexOf("/"));
 await Bun.$`mkdir -p ${dir}`.quiet();
 const line=JSON.stringify({ts:new Date().toISOString(),state,question,choices,...result})+"\n";
 await Bun.write(LOG,line,{createPath:true,append:true} as any);
}catch{}
console.log(JSON.stringify(result));
