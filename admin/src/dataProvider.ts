import postgrestRestProvider from "@raphiniert/ra-data-postgrest";
import { fetchUtils } from "react-admin";
import { TOKEN_KEY } from "./authProvider";

const httpClient = (url: string, options: fetchUtils.Options = {}) => {
  const token = localStorage.getItem(TOKEN_KEY);
  const headers = new Headers(options.headers);

  if (token) {
    headers.set("Authorization", `Bearer ${token}`);
  }

  return fetchUtils.fetchJson(url, { ...options, headers });
};

const dataProvider = postgrestRestProvider({
    apiUrl: "/postgrest",
    httpClient,
    defaultListOp: "eq",
    primaryKeys: new Map([
        ["colony", ["name"]],
    ]),
    schema: () => "public",
});

export default dataProvider;
