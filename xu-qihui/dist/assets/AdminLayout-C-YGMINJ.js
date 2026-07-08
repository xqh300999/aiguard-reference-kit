import{d as x,u as z,c as V,a as e,b as t,w as a,t as r,j as h,r as i,f as A,k as n,g as p,l as C,e as L,E as N}from"./index-B_QOIWrT.js";import{L as R,S,a as j}from"./shield-check-C3k2ZguI.js";import{c as u}from"./createLucideIcon-CvWb003y.js";/**
 * @license lucide-vue-next v1.0.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const q=u("building-2",[["path",{d:"M10 12h4",key:"a56b0p"}],["path",{d:"M10 8h4",key:"1sr2af"}],["path",{d:"M14 21v-3a2 2 0 0 0-4 0v3",key:"1rgiei"}],["path",{d:"M6 10H4a2 2 0 0 0-2 2v7a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-2",key:"secmi2"}],["path",{d:"M6 21V5a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v16",key:"16ra0t"}]]);/**
 * @license lucide-vue-next v1.0.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const B=u("circle-user",[["circle",{cx:"12",cy:"12",r:"10",key:"1mglay"}],["circle",{cx:"12",cy:"10",r:"3",key:"ilqhr7"}],["path",{d:"M7 20.662V19a2 2 0 0 1 2-2h6a2 2 0 0 1 2 2v1.662",key:"154egf"}]]);/**
 * @license lucide-vue-next v1.0.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const D=u("monitor-smartphone",[["path",{d:"M18 8V6a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2v7a2 2 0 0 0 2 2h8",key:"10dyio"}],["path",{d:"M10 19v-3.96 3.15",key:"1irgej"}],["path",{d:"M7 19h5",key:"qswx4l"}],["rect",{width:"6",height:"10",x:"16",y:"12",rx:"2",key:"1egngj"}]]);/**
 * @license lucide-vue-next v1.0.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const E=u("triangle-alert",[["path",{d:"m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3",key:"wmoenq"}],["path",{d:"M12 9v4",key:"juzpu7"}],["path",{d:"M12 17h.01",key:"p32p05"}]]);/**
 * @license lucide-vue-next v1.0.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const H=u("users",[["path",{d:"M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2",key:"1yyitq"}],["path",{d:"M16 3.128a4 4 0 0 1 0 7.744",key:"16gr8j"}],["path",{d:"M22 21v-2a4 4 0 0 0-3-3.87",key:"kshegd"}],["circle",{cx:"9",cy:"7",r:"4",key:"nufk8"}]]),I={class:"app-shell"},T={class:"side-nav"},U={class:"nav-list"},G={class:"main-shell"},O={class:"top-bar"},F={class:"top-actions"},J={class:"user-chip",type:"button"},K={class:"content-area"},Y=x({__name:"AdminLayout",setup(P){const m=z(),c=C(),y=L(),_=h(()=>{const o={"/admin/dashboard":"数据总览","/admin/communities":"社区管理","/admin/elderly":"老人档案","/admin/users":"用户管理","/admin/devices":"设备管理","/admin/alerts":"告警管理"};return c.name==="AlertDetail"?"告警详情":o[c.path]||"管理后台"}),k=h(()=>{var o;return(((o=m.user)==null?void 0:o.realName)||"管").slice(0,1)}),g=o=>{o==="logout"&&(m.logout(),N.success("退出成功"),y.push("/login"))};return(o,s)=>{const l=i("RouterLink"),v=i("el-tag"),f=i("el-dropdown-item"),M=i("el-dropdown-menu"),w=i("el-dropdown"),b=i("RouterView");return A(),V("div",I,[e("aside",T,[t(l,{class:"brand",to:"/admin/dashboard"},{default:a(()=>[...s[0]||(s[0]=[e("span",{class:"brand-mark"},"A",-1),e("span",null,[e("strong",null,"AiGuard"),e("small",null,"管理后台")],-1)])]),_:1}),e("nav",U,[t(l,{class:"nav-item",to:"/admin/dashboard"},{default:a(()=>[t(n(R),{size:18}),s[1]||(s[1]=e("span",null,"数据总览",-1))]),_:1}),t(l,{class:"nav-item",to:"/admin/communities"},{default:a(()=>[t(n(q),{size:18}),s[2]||(s[2]=e("span",null,"社区管理",-1))]),_:1}),t(l,{class:"nav-item",to:"/admin/elderly"},{default:a(()=>[t(n(H),{size:18}),s[3]||(s[3]=e("span",null,"老人档案",-1))]),_:1}),t(l,{class:"nav-item",to:"/admin/users"},{default:a(()=>[t(n(B),{size:18}),s[4]||(s[4]=e("span",null,"用户管理",-1))]),_:1}),t(l,{class:"nav-item",to:"/admin/devices"},{default:a(()=>[t(n(D),{size:18}),s[5]||(s[5]=e("span",null,"设备管理",-1))]),_:1}),t(l,{class:"nav-item",to:"/admin/alerts"},{default:a(()=>[t(n(E),{size:18}),s[6]||(s[6]=e("span",null,"告警管理",-1))]),_:1})])]),e("section",G,[e("header",O,[e("div",null,[s[7]||(s[7]=e("p",{class:"top-eyebrow"},r("管理后台"),-1)),e("h1",null,r(_.value),1)]),e("div",F,[t(v,{type:"success",effect:"light"},{default:a(()=>{var d;return[t(n(S),{size:14}),p(" "+r(((d=n(m).user)==null?void 0:d.role)||"ADMIN"),1)]}),_:1}),t(w,{trigger:"click",onCommand:g},{dropdown:a(()=>[t(M,null,{default:a(()=>[t(f,{command:"logout"},{default:a(()=>[t(n(j),{size:16}),s[8]||(s[8]=p(" 退出登录 ",-1))]),_:1})]),_:1})]),default:a(()=>{var d;return[e("button",J,[e("span",null,r(k.value),1),p(" "+r(((d=n(m).user)==null?void 0:d.realName)||"管理员"),1)])]}),_:1})])]),e("main",K,[t(b)])])])}}});export{Y as default};
