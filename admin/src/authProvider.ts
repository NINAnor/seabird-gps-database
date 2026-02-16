import type { AuthProvider } from "react-admin";
import { SignJWT } from "jose";

const TOKEN_KEY = "auth_token";

const authProvider: AuthProvider = {
  login: async ({ username, password }: { username: string; password: string }) => {
    if (!username || !password) {
      throw new Error("Please enter both a role and a secret");
    }

    const secret = new TextEncoder().encode(password);
    const token = await new SignJWT({ role: username })
      .setProtectedHeader({ alg: "HS256" })
      .sign(secret);

    // Validate the token by making a test request to PostgREST
    const response = await fetch("/postgrest/", {
      headers: { Authorization: `Bearer ${token}` },
    });

    if (!response.ok) {
      throw new Error("Invalid credentials");
    }

    localStorage.setItem(TOKEN_KEY, token);
    localStorage.setItem("username", username);
  },

  logout: async () => {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem("username");
  },

  checkAuth: async () => {
    if (!localStorage.getItem(TOKEN_KEY)) {
      throw new Error("Not authenticated");
    }
  },

  checkError: async (error: { status?: number }) => {
    if (error.status === 401 || error.status === 403) {
      localStorage.removeItem(TOKEN_KEY);
      throw new Error("Session expired");
    }
  },

  getIdentity: async () => ({
    id: "admin",
    fullName: localStorage.getItem("username") || "Admin",
  }),

  getPermissions: async () => {
    const token = localStorage.getItem(TOKEN_KEY);
    if (!token) return [];
    try {
      const payload = JSON.parse(atob(token.split(".")[1]));
      return payload.role ? [payload.role] : [];
    } catch {
      return [];
    }
  },
};

export default authProvider;
export { TOKEN_KEY };
