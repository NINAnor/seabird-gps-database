import { Admin, Resource, ListGuesser, EditGuesser, ShowGuesser } from "react-admin";
import authProvider from "./authProvider";
import dataProvider from "./dataProvider";

const App = () => (
  <Admin
    dataProvider={dataProvider}
    authProvider={authProvider}
    requireAuth
  >
    <Resource name="animal" list={ListGuesser} edit={EditGuesser} show={ShowGuesser} />
    <Resource name="colony" list={ListGuesser} edit={EditGuesser} show={ShowGuesser} />
    <Resource name="deployment" list={ListGuesser} edit={EditGuesser} show={ShowGuesser} />
    <Resource name="ring" list={ListGuesser} edit={EditGuesser} show={ShowGuesser} />
    <Resource name="logger" list={ListGuesser} edit={EditGuesser} show={ShowGuesser} />
    <Resource name="logger_instrumentation" list={ListGuesser} edit={EditGuesser} show={ShowGuesser} />
    <Resource name="chick" list={ListGuesser} edit={EditGuesser} show={ShowGuesser} />
  </Admin>
);

export default App;

