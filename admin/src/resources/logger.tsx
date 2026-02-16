import {
  List,
  Datagrid,
  TextField,
  Show,
  SimpleShowLayout,
  Edit,
  SimpleForm,
  TextInput,
  required,
} from "react-admin";

const LoggerFilter = [
    <TextInput label="Search" source="id" alwaysOn />,
    <TextInput label="Type" source="type" />,
    <TextInput label="Model" source="model" />,
];

export const LoggerList = () => (
  <List perPage={25} filters={LoggerFilter}>
    <Datagrid rowClick="show">
      <TextField source="id" />
      <TextField source="type" />
      <TextField source="model" />
    </Datagrid>
  </List>
);

export const LoggerShow = () => (
  <Show>
    <SimpleShowLayout>
      <TextField source="id" />
      <TextField source="type" />
      <TextField source="model" />
    </SimpleShowLayout>
  </Show>
);

export const LoggerEdit = () => (
  <Edit>
    <SimpleForm>
      <TextInput source="id" disabled />
      <TextInput source="type" validate={required()} />
      <TextInput source="model" />
    </SimpleForm>
  </Edit>
);
