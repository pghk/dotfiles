const alphas = (str) => str.replace(/^(\d{2}[\.–])?(\d{2}) /g, "");
const digits = (str) => {
  const matches = str.match(/^(\d{2}[\.–])?(\d{2})/);
  return matches[0];
};
const pad = (n) => n.toString().padStart(2, 0);

class JohnnyDecimal {
  constructor(templater) {
    this.tp = templater;
    this.file = templater.file.title;
  }

  async createArea() {
    const { start, end } = await this.nextArea();
    const name = await this.tp.system.prompt("Area name", "New Area");
    const category = `${pad(start + 1)} ${name}`;
    const subject = `${pad(start + 1)}.01 ${name}`;
    const range = `${pad(start)}–${pad(end)}`;
    const path = `${range} ${name}/${category}/${subject}`;
    await this.tp.file.move(`/${path}/${this.file}`);
  }

  async createCategory() {
    const area = await this.chooseArea();
    const name = await this.tp.system.prompt("Category name", "New Category");
    const id = await this.nextCategory(area);
    const category = `${pad(id)} ${name}`;
    const subject = `/${pad(id)}.01 ${name}/`;
    const path = `${area}/${category}/${subject}`;
    await this.tp.file.move(`/${path}/${this.file}`);
  }

  async createSubject() {
    const category = await this.chooseCategory();
    const name = await this.tp.system.prompt("Subject name", "New Subject");
    const cid = category.split("/").slice(-1)[0].substring(0, 2);
    const id = await this.nextSubject(category);
    const subject = `${cid}.${pad(id)} ${name}`;
    const path = `${category}/${subject}`;
    await this.tp.file.move(`/${path}/${this.file}`);
  }

  listAreas() {
    return this.getList(".", 1);
  }

  listCategories() {
    return this.getList(".", 2);
  }

  listSubjects() {
    return this.getList(".", 3);
  }

  chooseArea() {
    const getValues = () => this.listAreas();
    const toText = (v) => ({ key: v.substring(2), value: v });
    return this.getChoice(getValues, toText);
  }

  chooseCategory() {
    const getValues = () => this.listCategories();
    const toText = (v) => {
      const [area, category] = v.substring(2).split("/");
      const k = `${digits(category)} / ${alphas(area)} / ${alphas(category)}`;
      return { key: k, value: v };
    };
    return this.getChoice(getValues, toText);
  }

  chooseSubject() {
    const getValues = () => this.listSubjects();
    const toText = (v) => {
      const [area, category, subject] = v.substring(2).split("/");
      const k =
        `${digits(subject)} / ${alphas(area)} / ` +
        `${alphas(category)} / ${alphas(subject)}`;
      return { key: k, value: v };
    };
    return this.getChoice(getValues, toText);
  }

  async getList(path, depth) {
    const result = await this.tp.user.johnnyDecimal({ path, depth });
    return result.split("\n").filter((i) => i);
  }

  async getChoice(getValues, toText) {
    const values = await getValues();
    const byText = (a, b) => (a.key == b.key ? 0 : a.key < b.key ? -1 : 1);
    const options = values.map(toText).sort(byText);
    return await this.tp.system.suggester(
      options.map((i) => i.key),
      options.map((i) => i.value),
    );
  }

  async nextArea() {
    const existing = await this.listAreas();
    if (!existing.length) {
      return { start: 0, end: 9 };
    }
    const ranges = existing
      .map((i) => i.substring(2))
      .map(digits)
      .map((i) => i.split("–"));
    const last = ranges.slice(-1)[0];
    const [start, end] = last.map((id) => parseInt(id) + 10);
    return { start, end };
  }

  async nextCategory(inArea) {
    const first = inArea.substring(2, 4);
    const existing = await this.getList(inArea, 1);
    const ids = existing
      .map((i) => i.substring(2))
      .map((i) => i.split("/").slice(-1)[0])
      .map(digits)
      .sort();
    const last = ids.slice(-1)[0] ?? first;
    return parseInt(last) + 1;
  }

  async nextSubject(inCategory) {
    const existing = await this.getList(inCategory, 1);
    const ids = existing
      .map((i) => i.substring(2))
      .map((i) => i.split("/").slice(-1)[0])
      .map((i) => i.split(".").slice(-1)[0])
      .map(digits)
      .sort();
    const last = ids.slice(-1)[0] ?? 0;
    return parseInt(last) + 1;
  }
}

module.exports = JohnnyDecimal;
