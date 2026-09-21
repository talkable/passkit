## [0.9.0]

- Name the pass bundle's image slots in `BasePass::IMAGE_FILE_NAMES`, and copy images
  into the bundle through `BasePass#install_images`. Adds the `primary_logo` slot the
  iOS 27 poster styles render (`primaryLogo.png`); `posterGeneric` never renders
  `logo.png`, so a poster pass had no way to show one.

## [0.8.0]

- Support the iOS 27 poster styles: `poster_pass_type`, `poster_primary_fields`,
  `footer_fields` and `featured_actions`. A pass that sets `poster_pass_type` emits
  both style dictionaries, so older devices keep rendering the classic layout.
- Fix `boarding_pass` being dropped: its keys were merged into a discarded copy of
  the `boardingPass` dictionary and never reached `pass.json`.

## [0.7.0]
- [#25](https://github.com/coorasse/passkit/pull/25): Change the label default color to black.

## [0.6.1]

- [#21](https://github.com/coorasse/passkit/pull/21): Support an ecryption key via `PASSKIT_URL_ENCRYPTION_KEY` environment variable.

## [0.6.0]

- [#20](https://github.com/coorasse/passkit/pull/20): Many new attributes added.

## [0.5.4]

- Fix last-modified header format. Return it in RFC 2616 format.

## [0.5.3]

- [#15](https://github.com/coorasse/passkit/pull/15): Send correct headers also on passes_controller


## [0.5.2]

- [#14](https://github.com/coorasse/passkit/pull/14): Send correct headers with previews so it auto-adds on iOS

## [0.5.1]

- [#13](https://github.com/coorasse/passkit/pull/13): Added sharingProhibited 
- [#13](https://github.com/coorasse/passkit/pull/13): Added maxDistance
- [#13](https://github.com/coorasse/passkit/pull/13): Allow custom files with add_other_files

## [0.5.0]

- Allow configuring labelColor
- Allow receiving the same push otken with different device identifiers
- Make the last_update more flexible

## [0.4.2]

- Fix the unregister endpoint.

## [0.4.1]

- Allow the registration of two passes on the same device.

## [0.4.0]

- Allow to use the dashboard also in production.
- Allow to protect the dashboard using different strategies. Basic auth is default.
- Breaking: now your Passkit dashboard is mounted under `/passkit/dashboard` instead of just `/passkit`. 

## [0.3.3]

- Fix previews page.

## [0.3.2]

## [0.3.1]

## [0.3.0]

## [0.2.0]

## [0.1.0]

- Initial release.
