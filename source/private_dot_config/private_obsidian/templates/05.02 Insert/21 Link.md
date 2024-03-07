<%*
// https://github.com/SilentVoid13/Templater/discussions/574#discussion-3908041
let url = await tp.system.clipboard(); // Paste link
// let url = await tp.file.selection().trim(); // Replace selected link
let page = await tp.obsidian.request({url});
let p = new DOMParser();
let doc = p.parseFromString(page, "text/html");
let $ = s => doc.querySelector(s);
let title = $("title")?.textContent || $("meta[property='title']")?.content;
let description = $("meta[name='description']")?.content || $("meta[property='og:description']")?.content;
-%>
[<% title %>](<% url %>)
><% description %>
