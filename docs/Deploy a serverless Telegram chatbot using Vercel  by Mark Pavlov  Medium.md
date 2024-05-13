[

![Mark Pavlov](https://miro.medium.com/v2/da:true/resize:fill:88:88/0*4M6MGD1oL3N8O62e)



](https://medium.com/@7rodma?source=post_page-----57665d942a58--------------------------------)

![telegram](https://miro.medium.com/v2/resize:fit:875/0*NjfkZAvKJstvmBHt)

Photo by [Dimitri Karastelev](https://unsplash.com/@dkfra19?utm_source=medium&utm_medium=referral) on [Unsplash](https://unsplash.com/?utm_source=medium&utm_medium=referral)

Telegram supports two ways of interacting with the messages that users send to its bots. One of them is using [webhooks](https://en.wikipedia.org/wiki/Webhook). This method fits perfectly with [serverless functions](https://en.wikipedia.org/wiki/Serverless_computing).

## Prepare, what you need first

1.  Create telegram bot — use [Botfather](https://t.me/botfather), and keep your **Telegram authorization** **token**.
2.  Create a Vercel account. Head to the [signup page](https://vercel.com/signup) and create a new account using your GitHub, GitLab, or BitBucket account.
3.  Create a basic Node.js project using `npm`.
4.  Install dependency: [telegraf](https://www.npmjs.com/package/telegraf) — Bot API framework for Node.js
5.  Install devDependencies, (need for Typescript): [@vercel/node](https://www.npmjs.com/package/@vercel/node), [typescript](https://www.npmjs.com/package/typescript), [@types/node](https://www.npmjs.com/package/@types/node), [@vercel/ncc](https://www.npmjs.com/package/@vercel/ncc)

```
<span id="65e8" data-selectable-paragraph="">npm i telegraf<br>npm i -D @vercel/node typescript @types/node @vercel/ncc</span>
```

6\. Create tsconfig.json file. `public` folder is default vercel build folder.

```
<span id="71ee" data-selectable-paragraph=""><span>{</span><br>  <span>"compilerOptions"</span><span>:</span> <span>{</span><br>    <span>"strict"</span><span>:</span> <span><span>true</span></span><span>,</span><br>    <span>"target"</span><span>:</span> <span>"esnext"</span><span>,</span><br>    <span>"moduleResolution"</span><span>:</span> <span>"node"</span><span>,</span><br>    <span>"module"</span><span>:</span> <span>"commonjs"</span><span>,</span><br>    <span>"outDir"</span><span>:</span> <span>"public"</span><span>,</span><br>    <span>"lib"</span><span>:</span> <span>[</span><span>"esnext"</span><span>,</span> <span>"dom"</span><span>]</span><span>,</span><br>    <span>"resolveJsonModule"</span><span>:</span> <span><span>true</span></span><br>  <span>}</span><span>,</span><br>  <span>"exclude"</span><span>:</span> <span>[</span><span>"node_modules"</span><span>]</span><br><span>}</span></span>
```

## Creating the Telegram bot message handler

Telegram expects to call a webhook by sending us a POST request when a message is send by the user. Let’s build the message handler to receive this.

```
<span id="4554" data-selectable-paragraph=""><br><br><span>import</span> { <span>VercelRequest</span>, <span>VercelResponse</span> } <span>from</span> <span>'@vercel/node'</span><br><span>import</span> { <span>Telegraf</span> } <span>from</span> <span>'telegraf'</span><br><span>import</span> { <span>Update</span> } <span>from</span> <span>'telegraf/typings/core/types/typegram'</span><br><span>import</span> { greeting } <span>from</span> <span>'./greeting'</span><br><br><br><span>const</span> <span>VERCEL_URL</span> = <span>`<span>${process.env.VERCEL_URL}</span>`</span><br><br><span>const</span> <span>BOT_TOKEN</span> = process.<span>env</span>.<span>BOT_TOKEN</span> || <span>''</span><br><br><span>const</span> bot = <span>new</span> <span>Telegraf</span>(<span>BOT_TOKEN</span>)<br><br><br>bot.<span>on</span>(<span>'message'</span>, <span>greeting</span>())<br><br><span>export</span> <span>const</span> <span>messageHandler</span> = <span>async</span> (<span><br>  req: VercelRequest,<br>  res: VercelResponse<br></span>) =&gt; {<br>  <span>if</span> (!<span>VERCEL_URL</span>) {<br>    <span>throw</span> <span>new</span> <span>Error</span>(<span>'VERCEL_URL is not set.'</span>)<br>  }<br><br>  <span>const</span> getWebhookInfo = <span>await</span> bot.<span>telegram</span>.<span>getWebhookInfo</span>()<br>  <span>if</span> (getWebhookInfo.<span>url</span> !== <span>VERCEL_URL</span> + <span>'/api'</span>) {<br>    <span>await</span> bot.<span>telegram</span>.<span>deleteWebhook</span>()<br>    <span>await</span> bot.<span>telegram</span>.<span>setWebhook</span>(<span>`<span>${VERCEL_URL}</span>/api`</span>)<br>  }<br><br>  <span>if</span> (req.<span>method</span> === <span>'POST'</span>) {<br>    <span>await</span> bot.<span>handleUpdate</span>(req.<span>body</span> <span>as</span> <span>unknown</span> <span>as</span> <span>Update</span>, res)<br>  } <span>else</span> {<br>    res.<span>status</span>(<span>200</span>).<span>json</span>(<span>'Listening to bot events...'</span>)<br>  }<br>}</span>
```

Let’s add some function for greeting people who will use our bot

```
<span id="6e95" data-selectable-paragraph=""><br><br><span>import</span> { <span>Context</span> } <span>from</span> <span>'telegraf'</span><br><br><span>export</span> <span>const</span> <span>greeting</span> = () =&gt; <span>async</span> (<span>ctx</span>: <span>Context</span>) =&gt; {<br>  <span>const</span> messageId = ctx.<span>message</span>?.<span>message_id</span><br>  <span>const</span> replyText = <span>`Hello <span>${ctx.message?.<span>from</span>.first_name}</span>`</span><br><br>  <span>if</span> (messageId) {<br>    <span>await</span> ctx.<span>reply</span>(replyText, { <span>reply_to_message_id</span>: messageId })<br>  }<br>}</span>
```

## Creating Vercel serverless function

Making a new serverless function is easy. Just create directory called `/api` in the root of your project. Inside that directory you can add an exported function and it will appear as an API route. Let's add a new function to handle our Telegram messages.

```
<span id="4276" data-selectable-paragraph=""><br><br><span>import</span> { <span>VercelRequest</span>, <span>VercelResponse</span> } <span>from</span> <span>'@vercel/node'</span>;<br><span>import</span> { startVercel } <span>from</span> <span>'../src'</span>;<br><br><span>export</span> <span>default</span> <span>async</span> <span>function</span> <span>handle</span>(<span>req: VercelRequest, res: VercelResponse</span>) {<br>  <span>try</span> {<br>    <span>await</span> <span>startVercel</span>(req, res);<br>  } <span>catch</span> (<span>e</span>: <span>any</span>) {<br>    res.<span>statusCode</span> = <span>500</span>;<br>    res.<span>setHeader</span>(<span>'Content-Type'</span>, <span>'text/html'</span>);<br>    res.<span>end</span>(<span>'&lt;h1&gt;Server Error&lt;/h1&gt;&lt;p&gt;Sorry, there was a problem&lt;/p&gt;'</span>);<br>    <span>console</span>.<span>error</span>(e.<span>message</span>);<br>  }<br>}</span>
```

## Setting up build command

To build telegram bot use [@vercel/ncc](https://www.npmjs.com/package/@vercel/ncc) cli. It compiling a Node.js module into a single file. Add build script in your `package.json`

```
<span id="443c" data-selectable-paragraph=""> <span>"build"</span><span>:</span> <span>"ncc build src/index.ts -o public -m"</span></span>
```

## Deploying to Vercel

First you need to push your project to any Git provider. After that you can import a repository from [Vercel](https://vercel.com/) or push it directly via [Vercel CLI](https://vercel.com/docs/cli).

Don’t forget to add a `BOT_TOKEN` environment variable before deploying telegram bot.

And that’s it. You’ve now got a serverless Telegram bot deployed to Vercel which can respond to user messages. Try typing some message in Telegram to your bot and check that it responds correctly.

## Test functions

Check your network — click on button `View Function Logs` . If all ok you’ll see telegram api requests

![](https://miro.medium.com/v2/resize:fit:875/1*xElsr0Yq_xUmxIQuJlNpuw.png)

## And finally…

I have created a template for launching the application locally and getting an easy start on Deploying to Vercel. Try it, if you don’t want to write a boilerplate code

## [telegram-bot-vercel-boilerplate](https://github.com/m7mark/telegram-bot-vercel-boilerplate)