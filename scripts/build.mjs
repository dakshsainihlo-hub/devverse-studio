import {cp,mkdir,rm} from 'node:fs/promises';

const root=new URL('../',import.meta.url);
const output=new URL('../dist/',import.meta.url);
await rm(output,{recursive:true,force:true});
await mkdir(output,{recursive:true});
for(const entry of ['index.html','privacy.html','terms.html','robots.txt','src']){
  await cp(new URL(entry,root),new URL(entry,output),{recursive:true});
}
for(const asset of ['config.js','favicon.svg']){
  await cp(new URL(`public/${asset}`,root),new URL(asset,output));
}
console.log('Static site copied to dist/.');
