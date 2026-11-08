# 一丝不苟 · Cited synthesis delivery

[English](#english) · [中文](#中文)

---

## English

> Every web answer, held to a paper's standard.

`dsh-cited-synthesis` adds one default rule to [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness): an answer built from a web search must carry a checkable link on every claim, state the conditions under which each claim holds, and list opposing findings instead of flattening them into "opinions differ".

It does not make the model smarter. It changes what the model shows you.

**Known limitation: answers get longer.** That is the trade.

### Scope: everyday search, not academic review

This bundle reads web pages: official notices, news, blog posts, vendor docs. It is not a literature-review tool.

- No access to scholarly databases (CNKI, PubMed, Web of Science, Scopus).
- No PRISMA or systematic-review workflow.
- No bibliographic verification (DOI, Crossref, page numbers).
- No reference-manager output.

Use it for travel planning, product comparison, policy lookup, fact checking. If you need a literature review, use a tool built for that — this one will only hand you a well-cited web summary.

### What gets registered

| Registered | Purpose | When it applies |
|---|---|---|
| prompt section `cited-synthesis-rules` | nine hard constraints, always present | every turn |
| skill `cited-synthesis-delivery` | full procedure: evidence ledger, condition dimensions, three-step disagreement test, delivery template, pre-delivery self-check, anti-patterns | loaded on demand |

The section costs roughly 200 tokens per turn. Everything long lives in the skill.

### The nine rules

1. Every substantive claim carries a link that supports that sentence — not "related reading". A number taken from a review's citation of a primary study must say so.
2. Classify the claim before wording it: observable fact; institutional fact (prices, opening hours — cite the document and its date); authoritative recommendation (name the body and the year, state the population); contested judgment (list conditions side by side); or your own advice (mark `[inference]` or say "my recommendation").
3. Write condition → conclusion. If the source gives no condition, write "condition not stated"; do not invent one.
4. Go looking for counter-evidence. When findings conflict, present them by condition instead of writing "opinions differ".
5. Label the evidence type: official notice / peer-reviewed / preprint / vendor claim / media.
6. Mark `[inference]` for anything beyond a single source: cross-source synthesis, causal attribution, cross-study ranking, one-line summaries, turning an association into a prescription. A summary that only condenses already-labeled findings may skip the tag.
7. Either explain a grading code on the spot (evidence level 2a, GRADE) or drop it.
8. End with "unverified" and "search scope".
9. Length scales with (cost of being wrong) × (genuine disagreement). A factual question gets one line and one link; recommendations must carry attribution.

### Install

```sh
npx @deepseek-ai/dsh web
```

Then install the bundle from the plugin manager, or through `plugin_manager`:

```
target: dsh-cited-synthesis
```

Host-only bundle. No runtime dependencies, no build step, no install scripts.

### Boundaries

- It guarantees the model *sees* the rules every turn, not that it follows them. A prompt is not a validator.
- Whether a link actually supports its sentence remains a human judgment. Sentence-level verification needs a separate pipeline and is out of scope here.
- On balance: when the evidence points one way, these rules require saying so. Forcing symmetry is its own distortion.

### Compatibility

Developed and verified against DSH `0.2.2-rc.1`. DSH is in developer preview and ships breaking changes; if the section or skill disappears after an upgrade, check the plugin row first.

### Attribution

Design informed by [xingtaxueshu/literature-review-skills](https://github.com/xingtaxueshu/literature-review-skills) (MIT, Copyright (c) 2026 StarTower Academic), specifically its contradiction matrix and source-integrity rules.

No text from that repository is copied here: the setting moved from scholarly literature to general web search, verification moved from DOI records to fetched page bodies, and a rule for marking cross-source inference was added. The credit is academic courtesy, not an endorsement by the original author.

### License

MIT — see [LICENSE](LICENSE).

---

## 中文

> 让 AI 的每次搜索都按论文的标准来。

给 [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) 加一条默认规则：**凡是联网检索得出的答案，都要带能核对的链接、写清成立条件、把相反结论摆出来。**

它不改变模型能做什么，只改变它怎么交付。

**已知问题：回答会变长。** 这是代价。

### 适用范围：日常搜索，不是学术综述

这个包读的是网页：官方公告、新闻、博客、厂商文档。它**不是文献综述工具**。

- 不接学术数据库（知网、PubMed、Web of Science、Scopus）
- 没有 PRISMA 或系统综述流程
- 不做题录核验（DOI、Crossref、页码）
- 不输出文献管理格式

适合旅行攻略、消费选购、政策查询、事实核查。要写文献综述，请用专门的工具——这个包只能给你一份引用齐全的网页摘要。

### 它注册什么

| 注册项 | 作用 | 什么时候生效 |
|---|---|---|
| system prompt 段落 `cited-synthesis-rules` | 九条硬约束，每次都出现 | 每一轮 |
| skill `cited-synthesis-delivery` | 完整流程：证据台账、条件维度、分歧三步判定、交付模板、交付前自检、反模式 | 模型按需加载 |

段落约占 200 token，长文本全部放在 skill 里，避免每轮付费。

### 九条约束

1. 每条实质结论后跟一个链接，链接必须直接支持这句话本身，不接受"相关阅读"；数字若来自某篇综述转引的原始研究，写明转引自哪里。
2. 先分清断言类型：可观测事实；制度性事实（票价、开放时间——引文件并注明日期）；权威建议（写明机构、年份、适用人群）；争议判断（按条件并列）；自身建议（标 `[推断]` 或明说"我的建议"）。
3. 写成"条件—结论"结构；来源没交代条件时写"条件未说明"，不要替它假设。
4. 主动找反例。存在相反结论时按条件并列，不要压成一句"存在争议"。
5. 标注证据类型：官方公告 / 同行评审 / 预印本 / 厂商自述 / 媒体。
6. 凡超出单一来源的表述都标 `[推断]`：跨来源拼接、因果归因、跨研究排序、一句话总括、把关联转成处方。总括若只是压缩下文已标注的结论，可省。
7. 专业分级代码（证据等级 2a、GRADE 高/低）要么当场解释，要么换成读者能懂的话。
8. 结尾列"未核实项"与"检索范围"。
9. 篇幅与"决策代价 × 真分歧"成正比：事实性问题一句话加一个链接；建议性问题必须带归属，不能靠缩短篇幅省掉。超长时先删重复与连接句，风险信息（来源冲突、概率、检修、未核实项）不删。

### 安装

```sh
npx @deepseek-ai/dsh web
```

然后在插件管理器里安装，或用 `plugin_manager`：

```
target: dsh-cited-synthesis
```

Host-only bundle，无运行时依赖，不需要构建步骤，没有安装脚本。

### 效果边界

- 它保证模型**每次都看到**这条规则，不保证每次都照做。提示词不是校验器。
- 链接是否真的支持那句话，最终仍要人判断。真正做逐句核验需要额外的管线，不在本包范围内。
- 与"平衡"有关的取舍：证据一边倒时，规则要求如实说一边倒，不要为了对称硬造反例。强行五五开本身是一种失真。

### 版本兼容

在 DSH `0.2.2-rc.1` 上开发和验证。DSH 处于 developer preview，破坏性变更随时可能发生；升级后如果段落或 skill 消失，先查插件行状态。

### 来源说明

设计思路受 [xingtaxueshu/literature-review-skills](https://github.com/xingtaxueshu/literature-review-skills)（MIT，Copyright (c) 2026 StarTower Academic）的 contradiction matrix 与 source-integrity 规则启发。

本包**未复制该仓库的任何文本**：场景从学术文献改为通用检索，核验口径从 DOI 题录改为网页正文抓取，并增补了跨来源推断的标注规则。署名出于学术惯例，不代表原作者背书。

### 许可

MIT，见 [LICENSE](LICENSE)。
