import {
  List,
  Datagrid,
  TextField,
  NumberField,
  BooleanField,
  ReferenceField,
  Show,
  SimpleShowLayout,
  Edit,
  SimpleForm,
  NumberInput,
  BooleanInput,
  ReferenceInput,
  SelectInput,
  required,
  TextInput,
} from "react-admin";

const ChickFilter = [
    <TextInput label="Search" source="id" alwaysOn />,
    <ReferenceInput source="deployment" reference="deployment" />,
];

export const ChickList = () => (
  <List perPage={25} filters={ChickFilter}>
    <Datagrid rowClick="show">
      <TextField source="id" />
      <ReferenceField source="deployment" reference="deployment" />
      <NumberField source="mass_deployment_g" />
      <NumberField source="age_deployment_days" />
      <NumberField source="mass_retrieval_g" />
      <NumberField source="age_retrieval_days" />
    </Datagrid>
  </List>
);

export const ChickShow = () => (
  <Show>
    <SimpleShowLayout>
      <TextField source="id" />
      <ReferenceField source="deployment" reference="deployment" />
      <NumberField source="mass_deployment_g" />
      <BooleanField source="mass_deployment_accurate" />
      <NumberField source="age_deployment_days" />
      <NumberField source="mass_retrieval_g" />
      <BooleanField source="mass_retrieval_accurate" />
      <NumberField source="age_retrieval_days" />
    </SimpleShowLayout>
  </Show>
);

export const ChickEdit = () => (
  <Edit>
    <SimpleForm>
      <TextField source="id" />
      <ReferenceInput source="deployment" reference="deployment">
        <SelectInput validate={required()} />
      </ReferenceInput>
      <NumberInput source="mass_deployment_g" />
      <BooleanInput source="mass_deployment_accurate" />
      <NumberInput source="age_deployment_days" />
      <NumberInput source="mass_retrieval_g" />
      <BooleanInput source="mass_retrieval_accurate" />
      <NumberInput source="age_retrieval_days" />
    </SimpleForm>
  </Edit>
);
