import { Admin, Resource } from "react-admin";
import authProvider from "./authProvider";
import dataProvider from "./dataProvider";
import { AnimalList, AnimalShow, AnimalEdit } from "./resources/animal";
import { ColonyList, ColonyShow, ColonyEdit } from "./resources/colony";
import { RingList, RingShow, RingEdit } from "./resources/ring";
import { DeploymentList, DeploymentShow, DeploymentEdit } from "./resources/deployment";
import { ChickList, ChickShow, ChickEdit } from "./resources/chick";
import { LoggerList, LoggerShow, LoggerEdit } from "./resources/logger";
import { LoggerInstrumentationList, LoggerInstrumentationShow, LoggerInstrumentationEdit } from "./resources/logger_instrumentation";
import PetsIcon from "@mui/icons-material/Pets";
import LocationCityIcon from "@mui/icons-material/LocationCity";
import CircleIcon from "@mui/icons-material/Circle";
import FlightTakeoffIcon from "@mui/icons-material/FlightTakeoff";
import EggIcon from "@mui/icons-material/Egg";
import GpsFixedIcon from "@mui/icons-material/GpsFixed";
import SettingsInputAntennaIcon from "@mui/icons-material/SettingsInputAntenna";

const App = () => (
  <Admin
    dataProvider={dataProvider}
    authProvider={authProvider}
    requireAuth
  >
    <Resource name="animal" list={AnimalList} show={AnimalShow} edit={AnimalEdit} icon={PetsIcon} />
    <Resource name="colony" list={ColonyList} show={ColonyShow} edit={ColonyEdit} icon={LocationCityIcon} />
    <Resource name="ring" list={RingList} show={RingShow} edit={RingEdit} icon={CircleIcon} />
    <Resource name="deployment" list={DeploymentList} show={DeploymentShow} edit={DeploymentEdit} icon={FlightTakeoffIcon} />
    <Resource name="chick" list={ChickList} show={ChickShow} edit={ChickEdit} icon={EggIcon} />
    <Resource name="logger" list={LoggerList} show={LoggerShow} edit={LoggerEdit} icon={GpsFixedIcon} />
    <Resource name="logger_instrumentation" list={LoggerInstrumentationList} show={LoggerInstrumentationShow} edit={LoggerInstrumentationEdit} icon={SettingsInputAntennaIcon} />
  </Admin>
);

export default App;

