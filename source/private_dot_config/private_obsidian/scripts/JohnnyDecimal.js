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

  async applyClassification() {
    const subject = await this.chooseSubject();
    if (subject) {
      return this.tp.file.move(`${subject}/${this.file}`);
    }
    const category = await this.chooseCategory();
    if (category) {
      return this.createSubject(category);
    }
    const area = await this.chooseArea();
    if (area) {
      return this.createCategory(area);
    }
    const newArea = await this.tp.system.prompt("Name Area", "New Area");
    if (newArea) {
      return this.createArea(newArea);
    }
    return;
  }

  async createArea(name) {
    const start = await this.nextArea();
    const cName = await this.tp.system.prompt("Name Category", "New Category");
    const sName = await this.tp.system.prompt("Name Subject", "New Subject");
    const category = `${pad(start + 1)} ${cName}`;
    const subject = `${pad(start + 1)}.01 ${sName}`;
    const path = `${start} ${name}/${category}/${subject}`;
    await this.tp.file.move(`/${path}/${this.file}`);
  }

  async createCategory(area) {
    const id = await this.nextCategory(area);
    const name = await this.tp.system.prompt("Name Category", "New Category");
    const sName = await this.tp.system.prompt("Name Subject", "New Subject");
    const category = `${pad(id)} ${name}`;
    const subject = `/${pad(id)}.01 ${sName}/`;
    const path = `${area}/${category}/${subject}`;
    await this.tp.file.move(`/${path}/${this.file}`);
  }

  async createSubject(category) {
    const name = await this.tp.system.prompt("Name Subject", "New Subject");
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
    return this.getChoice(getValues, toText, "Select Area");
  }

  chooseCategory() {
    const getValues = () => this.listCategories();
    const toText = (v) => {
      const [a, c] = v.substring(2).split("/");
      const k = `${digits(c)} ${alphas(a)}·${alphas(c)}`;
      return { key: k, value: v };
    };
    return this.getChoice(getValues, toText, "Pick a Category");
  }

  chooseSubject() {
    const getValues = () => this.listSubjects();
    const toText = (v) => {
      const [a, c, s] = v.substring(2).split("/");
      const k = `${digits(s)} ${alphas(a)}·${alphas(c)}·${alphas(s)}`;
      return { key: k, value: v.substring(2) };
    };
    return this.getChoice(getValues, toText, "Move to Subject");
  }

  async getList(path, depth) {
    const result = await this.tp.user.johnnyDecimal({ path, depth });
    return result.split("\n").filter((i) => i);
  }

  async getChoice(getValues, toText, placeholder = "") {
    const values = await getValues();
    const byText = (a, b) => (a.key == b.key ? 0 : a.key < b.key ? -1 : 1);
    const options = values.map(toText).sort(byText);
    return await this.tp.system.suggester(
      options.map((i) => i.key),
      options.map((i) => i.value),
      false,
      placeholder,
    );
  }

  async nextArea() {
    const existing = await this.listAreas();
    if (!existing.length) {
      return 0;
    }
    const last = existing
      .map((i) => i.substring(2))
      .map(digits)
      .sort()
      .slice(-1);
    return parseInt(last) + 10;
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
