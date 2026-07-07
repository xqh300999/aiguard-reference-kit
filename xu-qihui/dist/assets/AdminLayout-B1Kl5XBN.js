import{j as v,d as L,u as N,c as B,a as t,b as a,w as n,t as k,k as l,l as M,r as m,f as R,g as f,m as H,e as q,E}from"./index-uwCPo69n.js";/**
 * @license lucide-vue-next v1.0.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const I=o=>{for(const e in o)if(e.startsWith("aria-")||e==="role"||e==="title")return!0;return!1};/**
 * @license lucide-vue-next v1.0.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const C=o=>o==="";/**
 * @license lucide-vue-next v1.0.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const S=(...o)=>o.filter((e,d,r)=>!!e&&e.trim()!==""&&r.indexOf(e)===d).join(" ").trim();/**
 * @license lucide-vue-next v1.0.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const b=o=>o.replace(/([a-z0-9])([A-Z])/g,"$1-$2").toLowerCase();/**
 * @license lucide-vue-next v1.0.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const U=o=>o.replace(/^([A-Z])|[\s-_]+(\w)/g,(e,d,r)=>r?r.toUpperCase():d.toLowerCase());/**
 * @license lucide-vue-next v1.0.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const $=o=>{const e=U(o);return e.charAt(0).toUpperCase()+e.slice(1)};/**
 * @license lucide-vue-next v1.0.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */var g={xmlns:"http://www.w3.org/2000/svg",width:24,height:24,viewBox:"0 0 24 24",fill:"none",stroke:"currentColor","stroke-width":2,"stroke-linecap":"round","stroke-linejoin":"round"};/**
 * @license lucide-vue-next v1.0.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const D=({name:o,iconNode:e,absoluteStrokeWidth:d,"absolute-stroke-width":r,strokeWidth:h,"stroke-width":_,size:p=g.width,color:c=g.stroke,...s},{slots:i})=>v("svg",{...g,...s,width:p,height:p,stroke:c,"stroke-width":C(d)||C(r)||d===!0||r===!0?Number(h||_||g["stroke-width"])*24/Number(p):h||_||g["stroke-width"],class:S("lucide",s.class,...o?[`lucide-${b($(o))}-icon`,`lucide-${b(o)}`]:["lucide-icon"]),...!i.default&&!I(s)&&{"aria-hidden":"true"}},[...e.map(w=>v(...w)),...i.default?[i.default()]:[]]);/**
 * @license lucide-vue-next v1.0.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const u=(o,e)=>(d,{slots:r,attrs:h})=>v(D,{...h,...d,iconNode:e,name:o},r);/**
 * @license lucide-vue-next v1.0.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const T=u("building-2",[["path",{d:"M10 12h4",key:"a56b0p"}],["path",{d:"M10 8h4",key:"1sr2af"}],["path",{d:"M14 21v-3a2 2 0 0 0-4 0v3",key:"1rgiei"}],["path",{d:"M6 10H4a2 2 0 0 0-2 2v7a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-2",key:"secmi2"}],["path",{d:"M6 21V5a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v16",key:"16ra0t"}]]);/**
 * @license lucide-vue-next v1.0.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const O=u("circle-user",[["circle",{cx:"12",cy:"12",r:"10",key:"1mglay"}],["circle",{cx:"12",cy:"10",r:"3",key:"ilqhr7"}],["path",{d:"M7 20.662V19a2 2 0 0 1 2-2h6a2 2 0 0 1 2 2v1.662",key:"154egf"}]]);/**
 * @license lucide-vue-next v1.0.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const P=u("layout-dashboard",[["rect",{width:"7",height:"9",x:"3",y:"3",rx:"1",key:"10lvy0"}],["rect",{width:"7",height:"5",x:"14",y:"3",rx:"1",key:"16une8"}],["rect",{width:"7",height:"9",x:"14",y:"12",rx:"1",key:"1hutg5"}],["rect",{width:"7",height:"5",x:"3",y:"16",rx:"1",key:"ldoo1y"}]]);/**
 * @license lucide-vue-next v1.0.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const Z=u("log-out",[["path",{d:"m16 17 5-5-5-5",key:"1bji2h"}],["path",{d:"M21 12H9",key:"dn1m92"}],["path",{d:"M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4",key:"1uf3rs"}]]);/**
 * @license lucide-vue-next v1.0.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const G=u("monitor-smartphone",[["path",{d:"M18 8V6a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2v7a2 2 0 0 0 2 2h8",key:"10dyio"}],["path",{d:"M10 19v-3.96 3.15",key:"1irgej"}],["path",{d:"M7 19h5",key:"qswx4l"}],["rect",{width:"6",height:"10",x:"16",y:"12",rx:"2",key:"1egngj"}]]);/**
 * @license lucide-vue-next v1.0.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const F=u("shield-check",[["path",{d:"M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z",key:"oel41y"}],["path",{d:"m9 12 2 2 4-4",key:"dzmm74"}]]);/**
 * @license lucide-vue-next v1.0.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const J=u("triangle-alert",[["path",{d:"m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3",key:"wmoenq"}],["path",{d:"M12 9v4",key:"juzpu7"}],["path",{d:"M12 17h.01",key:"p32p05"}]]);/**
 * @license lucide-vue-next v1.0.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const Q=u("users",[["path",{d:"M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2",key:"1yyitq"}],["path",{d:"M16 3.128a4 4 0 0 1 0 7.744",key:"16gr8j"}],["path",{d:"M22 21v-2a4 4 0 0 0-3-3.87",key:"kshegd"}],["circle",{cx:"9",cy:"7",r:"4",key:"nufk8"}]]),X={class:"app-shell"},Y={class:"side-nav"},K={class:"nav-list"},W={class:"main-shell"},ee={class:"top-bar"},te={class:"top-eyebrow"},se={class:"top-actions"},ae={class:"user-chip",type:"button"},oe={class:"content-area"},re=L({__name:"AdminLayout",setup(o){const e=N(),d=H(),r=q(),h=M(()=>({"/admin/dashboard":"数据总览","/admin/communities":"社区管理","/admin/elderly":"老人档案","/admin/users":"用户管理","/admin/devices":"设备管理","/admin/alerts":"告警管理"})[d.path]||"管理后台"),_=M(()=>{var c;return(((c=e.user)==null?void 0:c.realName)||"管").slice(0,1)}),p=c=>{c==="logout"&&(e.logout(),E.success("退出成功"),r.push("/login"))};return(c,s)=>{var x;const i=m("RouterLink"),w=m("el-tag"),A=m("el-dropdown-item"),V=m("el-dropdown-menu"),z=m("el-dropdown"),j=m("RouterView");return R(),B("div",X,[t("aside",Y,[a(i,{class:"brand",to:"/admin/dashboard"},{default:n(()=>[...s[0]||(s[0]=[t("span",{class:"brand-mark"},"A",-1),t("span",null,[t("strong",null,"AiGuard"),t("small",null,"管理后台")],-1)])]),_:1}),t("nav",K,[a(i,{class:"nav-item",to:"/admin/dashboard"},{default:n(()=>[a(l(P),{size:18}),s[1]||(s[1]=t("span",null,"数据总览",-1))]),_:1}),a(i,{class:"nav-item",to:"/admin/communities"},{default:n(()=>[a(l(T),{size:18}),s[2]||(s[2]=t("span",null,"社区管理",-1))]),_:1}),a(i,{class:"nav-item",to:"/admin/elderly"},{default:n(()=>[a(l(Q),{size:18}),s[3]||(s[3]=t("span",null,"老人档案",-1))]),_:1}),a(i,{class:"nav-item",to:"/admin/users"},{default:n(()=>[a(l(O),{size:18}),s[4]||(s[4]=t("span",null,"用户管理",-1))]),_:1}),a(i,{class:"nav-item",to:"/admin/devices"},{default:n(()=>[a(l(G),{size:18}),s[5]||(s[5]=t("span",null,"设备管理",-1))]),_:1}),a(i,{class:"nav-item",to:"/admin/alerts"},{default:n(()=>[a(l(J),{size:18}),s[6]||(s[6]=t("span",null,"告警管理",-1))]),_:1})])]),t("section",W,[t("header",ee,[t("div",null,[t("p",te,k(((x=l(e).user)==null?void 0:x.communityName)||"管理后台"),1),t("h1",null,k(h.value),1)]),t("div",se,[a(w,{type:"success",effect:"light"},{default:n(()=>{var y;return[a(l(F),{size:14}),f(" "+k(((y=l(e).user)==null?void 0:y.role)||"ADMIN"),1)]}),_:1}),a(z,{trigger:"click",onCommand:p},{dropdown:n(()=>[a(V,null,{default:n(()=>[a(A,{command:"logout"},{default:n(()=>[a(l(Z),{size:16}),s[7]||(s[7]=f(" 退出登录 ",-1))]),_:1})]),_:1})]),default:n(()=>{var y;return[t("button",ae,[t("span",null,k(_.value),1),f(" "+k(((y=l(e).user)==null?void 0:y.realName)||"管理员"),1)])]}),_:1})])]),t("main",oe,[a(j)])])])}}});export{re as default};
