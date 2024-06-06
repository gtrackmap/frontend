<script lang="ts">
  export let id: string;
  let className: string | undefined = undefined
  export { className as class }
</script>

<svg class="icon icon-{id} {className}">
  <use xlink:href="#icon-{id}"></use>
</svg>
