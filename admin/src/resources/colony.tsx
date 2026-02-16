import {
  List,
  Datagrid,
  TextField,
  Show,
  SimpleShowLayout,
  Edit,
  SimpleForm,
  TextInput,
} from "react-admin";

const ColonyFilter = [
    <TextInput label="Search" source="name" alwaysOn />,
    <TextInput label="Country" source="country" />,
    <TextInput label="Plot" source="plot" />,
];

export const ColonyList = () => (
  <List perPage={25} filters={ColonyFilter}>
    <Datagrid rowClick="show">
      <TextField source="name" />
      <TextField source="country" />
      <TextField source="plot" />
      <TextField source="nest_id" />
    </Datagrid>
  </List>
);

export const ColonyShow = () => (
  <Show>
    <SimpleShowLayout>
      <TextField source="name" />
      <TextField source="country" />
      <TextField source="plot" />
      <TextField source="nest_id" />
    </SimpleShowLayout>
  </Show>
);

export const ColonyEdit = () => (
  <Edit>
    <SimpleForm>
      <TextInput source="name" disabled />
      <TextInput source="country" />
      <TextInput source="plot" />
      <TextInput source="nest_id" />
    </SimpleForm>
  </Edit>
);
