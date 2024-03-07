<%*
  let title = tp.user.toTitleCase(tp.file.title)
  if (title.startsWith("Untitled")) {
    title = await tp.system.prompt("Title");
  } 
  await tp.file.rename(title);
-%>
# <% title %>

<% tp.file.cursor() %>